class HackInspectorGroupedTable extends Grid.Controller
  @template 'hack_inspector_grouped_table'

  actions: 'click .delete': 'delete'

  # Helpers

  @inputTableName: (table) ->
    Tables.findOne(table.inputTableId)?.title

  @columns: (table) ->
    input = Tables.findOne(table.inputTableId)
    TableColumns.findArray(input.columnIds)

  # Actions

  delete: ->
    Tables.remove(_id: @data._id)
    Session.set('selection', null)