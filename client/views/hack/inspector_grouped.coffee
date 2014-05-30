class HackInspectorGroupedTable extends Grid.Controller
  @template 'hack_inspector_grouped_table'

  actions:
    'click .delete': 'delete'
    'change select.group-column': 'changeGroupColumn'

  # Helpers

  @inputTableName: (table) ->
    Tables.findOne(table.inputTableId)?.title

  @columns: (table) ->
    input = Tables.findOne(table.inputTableId)
    TableColumns.findArray(input.columnIds)

  # Events

  rendered: ->
    console.log 'highlight selected option', @data.groupColumnIndex
    console.log 'el', @$el
    @$('select.group-column').val(@data.groupColumnIndex)

  # Actions

  delete: ->
    Tables.remove(_id: @data._id)
    Session.set('selection', null)

  changeGroupColumn: (column) ->
    table = @data
    console.log 'updating column id to', @$('select.group-column').val()
    Tables.set table._id, {groupColumnIndex: @$('select.group-column').val()}
