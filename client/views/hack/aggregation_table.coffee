class AggregationTable extends Grid.Controller
  @template 'hack_index_aggregation_table'
  @extend DataHelpers

  constructor: ->
    @manager = Grid.DataManager.instance()

  @dataPreview: (table) ->
    data = @manager.dataForTable(table)
    preview = data.data()
    @constructor.dataForTemplate(preview)

  @columns: (table) ->
    @manager.columnsForTable(table)