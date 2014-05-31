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

    if Meteor.isClient
      Meteor.startup =>
        Tables.find().observeChanges
          # Here also we should only observe for changes in source and reload it.
          # This logic should also be moved to something called "Loader."
          changed: (id, fields) =>
            if fields['url'] or fields['groupColumnIndex']
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
    console.log("%cRequesting data for #{table.title}", "color: red;");
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
      return

    # Set data
    @_tables[table._id].data = data

    # Update the UI
    console.log("%cUpdating UI for table #{table.title}", "color: green;");
    @_tables[table._id].uiDep.changed()

  setDataToEmpty: (table) ->
    @_tables[table._id].data = @emptyData(table)

  emptyData: (table) ->
    if table.type is Tables.SOURCE
      new Grid.Data()
    else if table.type is Tables.GROUPED
      new Grid.GroupedData()

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
    console.log("%cFinished evaluating #{table.title}", "background-color: #d77d13; color: #fff");
    @setTableStatus(table, READY)
    @setDataToEmpty(table)

  finishEval: (table, data) ->
    console.log("%cFinished evaluating #{table.title}", "background-color: #d77d13; color: #fff");
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
    console.log 'tables', @_tables

    infos = (info for id, info of @_tables when info.status == NEEDS_EVAL)
    for info in infos
      @evaluateTable(info.table)

  evaluateTable: (table) ->
    @setTableStatus(table, EVALUATING)

    console.log("%cEvaluating #{table.title}", "background-color: #f68f16; color: #fff");

    if table.type is Tables.SOURCE
      @evaluateSourceTable(table)
    else if table.type is Tables.GROUPED
      @evaluateGroupedTable(table)
    else
      throw new Error("Cannot evaluate table of unknown type #{table.type}")

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

    console.log '<<< EVALUATING GROUPED TABLE >>>'
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
    
    console.log 'grouped data', groupedData

    @finishEval(table, groupedData)


class Grid.Data
  constructor: (data) ->
    # TODO: Instead of expecting prepared cached data,
    # figure out the whole trip to server and caching
    # and stuff like that.

    if !data
      @_isEmpty = true
      return

    @_data = data

  preview: -> @_data
  data: -> @_data
  metadata: -> @_metadata
  isEmpty: -> @_isEmpty

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