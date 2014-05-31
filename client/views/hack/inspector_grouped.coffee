class HackInspectorGroupedTable extends Grid.Controller
  @extend ItemsHelpers
  @template 'hack_inspector_grouped_table'
  @include TableActions

  actions:
    'click .delete': 'delete'
    'change select.group-column': 'changeGroupColumn'

  # Helpers

  # Events

  rendered: ->
    @$('select.group-column').val(@data.groupColumnIndex)

  changeGroupColumn: (column) ->
    table = @data
    Tables.set table._id, {groupColumnIndex: @$('select.group-column').val()}
