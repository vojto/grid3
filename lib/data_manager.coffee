@Grid or= {}

_instance = null

READY = 'ready'
NEEDS_EVAL = 'needs_eval'
EVALUATING = 'evaluating'

class Grid.DataManager
  @instance: ->
    _instance = new @() unless _instance
    _instance

  constructor: ->
    @_tables = {}
    # Key: Table ID
    # Value: Array of table IDs that depend on that table
    @_deps = {}

    @log = new Logger(enabled: false)

    if Meteor.isClient
      Meteor.startup =>
        Tables.find().observeChanges
          # Here also we should only observe for changes in source and reload it.
          # This logic should also be moved to something called "Loader."
          changed: (id, fields) =>
            if 'url' of fields or 'groupColumnIndex' of fields or 'aggregations' of fields
              setTimeout =>
                @markTableNeedingEval(Tables.findOne(id))
              , 0

  # Managing tables
  # ------------------------------------------------------------------

  addTable: (table) ->
    return if @_tables[table._id]

    if table.inputTableId
      depIds = [table.inputTableId]
    else
      depIds = []

    @_tables[table._id] =
      table: table
      data: @emptyData(table)
      status: NEEDS_EVAL
      # This dependency is only used for updating the user interface
      # not tracking cross-table dependencies.
      uiDep: new Deps.Dependency()
      dependsOn: depIds


    # Evaluate tables in the next run loop, to store all tables needed
    # for the UI, so we could compute in one run.
    @scheduleEvaluation()

  # Tries to get data for a table. If it wasn't added previously, schedules an 
  # evaluation. When this is called after a table has been added previously, then
  # doesn't schedule evaluation.
  dataForTable: (table) ->
    # console.log("%cRequesting data for #{table.title}", "color: red;");
    @addTable(table)
    @depend(table)
    @_tables[table._id].data

  # Marks UI dependency on a table
  depend: (table) ->
    @_tables[table._id].uiDep.depend()


  columnsForTable: (table) ->
    TableColumns.findArray(table.columnIds)

  # Managing data in tables
  # ------------------------------------------------------------------

  setData: (table, data) ->
    if data.isEmpty() && @_tables[table._id].data.isEmpty()
      console.log 'returning because both datasets are empty'
      return

    # Set data
    @_tables[table._id].data = data

    # Update the UI
    @log.green0("Updating UI for table #{table.title}, data size: #{data.length()}")
    @_tables[table._id].uiDep.changed()

  setDataToEmpty: (table) ->
    @_tables[table._id].data = @emptyData(table)

  emptyData: (table) ->
    if table.type is Tables.SOURCE
      new Grid.Data()
    else if table.type is Tables.GROUPED
      new Grid.GroupedData()
    else if table.type is Tables.AGGREGATION
      new Grid.Data()
    else
      throw new Error("Cant create empty data for table type #{table.type}")
      

  # Marking evaluation
  # ------------------------------------------------------------------

  markDependentTablesNeedingEval: (table) ->
    # Reverse order of dependencies
    dependentTables = []
    for id, info of @_tables
      if table._id in info.dependsOn
        dependentTables.push(info.table)

    @markTableNeedingEval(table) for table in dependentTables

  markTableNeedingEval: (table) ->
    @log.green1("Marking needing eval #{table.title}, current status: #{@tableStatus(table)}")
    unless @tableStatus(table) == EVALUATING
      @setTableStatus(table, NEEDS_EVAL)
      @scheduleEvaluation()

  tableStatus: (table) ->
    @_tables[table._id].status

  setTableStatus: (table, status) ->
    @_tables[table._id].status = status

  # Updating eval SM
  # ------------------------------------------------------------------

  cancelEval: (table) ->
    @log.orange2("Cancelling evaluation of #{table.title}")
    @setTableStatus(table, READY)
    @setDataToEmpty(table)

  finishEval: (table, data) ->
    @log.orange2("Finished evaluating #{table.title}")
    @setTableStatus(table, READY)
    @setData(table, data)

    # Re-evaluate tables that depend on it
    @markDependentTablesNeedingEval(table)

  # Evaluation
  # ------------------------------------------------------------------

  scheduleEvaluation: ->
    clearTimeout(@evaluateTimer)
    @evaluateTimer = setTimeout @evaluateTables.bind(@), 0

  evaluateTables: ->
    infos = (info for id, info of @_tables when info.status == NEEDS_EVAL)
    for info in infos
      @evaluateTable(info.table)

  evaluateTable: (table) ->
    @setTableStatus(table, EVALUATING)

    @log.orange1("Evaluating #{table.title}")

    if table.type is Tables.SOURCE
      @evaluateSourceTable(table)
    else if table.type is Tables.GROUPED
      @evaluateGroupedTable(table)
    else if table.type is Tables.AGGREGATION
      @evaluateAggregationTable(table)
    else
      @log.red1("Don't know how to evaluate table of type #{table.type}")

  evaluateSourceTable: (table) ->
    table = Tables.findOne(table._id)
    if not table.url or table.url == ''
      return @cancelEval(table)
    Meteor.call 'sources.load', table._id, (err, data) =>
      return @cancelEval(table) if Flash.handle(err)
      @handleTableDataReceive(table, data)

  # This method does THREE important things:
  # 1. Updates the schema based on received data
  # 2. Processes received data (for now automatically, later it
  # will use the schema -- should user have modified it)
  # 3. Store data in cache for display and further processing
  handleTableDataReceive: (table, data) ->
    metadata = new Grid.Metadata(data)

    # 1. Wipe existing columns (if user made any modifications --
    # too bad, changing the URL removes all columns and creates
    # the automatically inferred from data.
    TableColumns.removeAllForTable(table)

    # Store columns
    columns = for columnName, i in metadata.columnNames()
      {title: columnName, type: metadata.typeForColumn(i)}
    TableColumns.insertForTable(table, columns)

    # Remove the header
    if metadata.hasHeader()
      data.splice(0, 1)

    data = data.filter (d) ->
      d.length == metadata.columns

    # Parse data using datatypes from metadata
    # TODO: Not make a copy with map, but instead do it in-place
    data = data.map (d) =>
      d.map (value, column) =>
        type = metadata.typeForColumn(column)
        if type == 'number'
          parseFloat(value)
        else if type == 'date'
          moment(value).toDate()
        else
          value

    # Set data
    @finishEval(table, new Grid.Data(data))

  evaluateGroupedTable: (table) ->
    table = Tables.findOne(table._id)

    inputTable = Tables.findOne(table.inputTableId)
    inputData = @dataForTable(inputTable)
    groupIndex = table.groupColumnIndex
    groupColumn = TableColumns.findOne(inputTable.columnIds[groupIndex])

    if inputData.isEmpty()
      return @cancelEval(table)

    if not groupColumn
      return @cancelEval(table)

    columns = TableColumns.findArray(inputTable.columnIds)
    columns.splice(table.groupColumnIndex, 1)
    TableColumns.removeAllForTable(table)
    TableColumns.insertForTable(table, columns)

    groupedData = new Grid.GroupedData()

    data = inputData.data()
    groups = {}
    for row in data
      groupValue = row[groupIndex]
      group = groups[groupValue]
      if !group
        group = groups[groupValue] = []
      row = row.map (d) -> d # copy row
      row.splice(groupIndex, 1)
      group.push(row)

    for group, rows of groups
      groupedData.addGroup(group, new Grid.Data(rows))

    @finishEval(table, groupedData)

  evaluateAggregationTable: (table) ->
    table = Tables.findOne(table._id)
    inputTable = Tables.findOne(table.inputTableId)
    preInputTable = Tables.findOne(inputTable.inputTableId)
    inputData = @dataForTable(inputTable)

    columns = []

    Log.blue1 'evaluation of aggregation table'

    # Create the column for group name -- ideally we will use the original
    # column name here from the group table.

    # Get the original group column
    groupColumn = TableColumns.findOne(preInputTable.columnIds[inputTable.groupColumnIndex])
    columns.push(groupColumn)

    # Add columns for aggregations
    for aggregation, i in table.aggregations
      columns.push
        title: aggregation.name
        type: 'number'
        index: i+1 # first is the group column name
    TableColumns.replaceColumns(table, columns)

    data = new Grid.Data()
    for group in inputData.groups()
      rows = inputData.dataForGroup(group).data()

      # Cells for resulting aggregation
      cells = [group]

      for aggregation in table.aggregations
        console.log 'function', aggregation.function
        values = _(rows).map (row) -> row[aggregation.columnIndex]
        result = if aggregation.function is 'count'
          _(values).size()
        else if aggregation.function is 'sum'
          _(values).sum()
        else if aggregation.function is 'min'
          _(values).min()
        else if aggregation.function is 'max'
          _(values).max()
        else if aggregation.function is 'avg'
          _(values).mean()
        else if aggregation.function is 'med'
          _(values).median()
        else
          NaN
        cells.push(result)
        # else if 
        

      data.addRow(cells)

    @finishEval(table, data)


class Grid.Data
  constructor: (data) ->
    # TODO: Instead of expecting prepared cached data,
    # figure out the whole trip to server and caching
    # and stuff like that.

    if !data
      @_data = []
      @_isEmpty = true
      return

    @_data = data

  preview: -> @_data
  data: -> @_data
  metadata: -> @_metadata
  isEmpty: -> @_isEmpty
  length: -> @_data?.length or 0

  addRow: (row) ->
    @_data.push(row)
    @_isEmpty = false if @_isEmpty


# This class holds structure of grouped data
# Does it also process the data? Apply the grouping?
# For now, lets make this just a dumb container and not deal with 
# that here. We might split processing into classes other that DataManager
# but it sure as hell won't be data container that will do the processing.
class Grid.GroupedData extends Grid.Data
  constructor: (groupedData) ->
    if !groupedData
      @_isEmpty = true

    @_groups = {}

  addGroup: (groupName, data) ->
    @_isEmpty = false
    @_groups[groupName] = data

  groups: ->
    _(@_groups).keys()

  dataForGroup: (group) ->
    @_groups[group]

  length: ->
    _(@_groups).size() or 0