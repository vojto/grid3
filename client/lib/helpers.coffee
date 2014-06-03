@ItemsHelpers =
  isSource: (item) ->
    item.collection == 'tables' && item.type == Tables.SOURCE
  isGraph: (item) ->
    item.collection == 'graphs'
  isGroupedTable: (item) ->
    item.collection == 'tables' && item.type == Tables.GROUPED
  isAggregationTable: (item) ->
    item.collection == 'tables' && item.type == Tables.AGGREGATION
  tables: ->
    Tables.find().fetch()
  graphs: ->
    Graphs.find().fetch()
  inputTableName: (table) ->
    Tables.findOne(table.inputTableId)?.title
  # TODO: Rename to inputTableColumns
  columns: (table) ->
    item = Session.get('selection')
    return [] unless item
    input = Tables.findOne(item.inputTableId)
    input or= Tables.findOne(item.tableId) # if it's a graph
    return [] unless input
    TableColumns.findArray(input.columnIds)

@TableActions =
  delete: ->
    Tables.remove(_id: @data._id)
    Session.set('selection', null)