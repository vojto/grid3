class AggregationTable extends Grid.Controller
  @template 'hack_index_aggregation_table'
  @extend DataHelpers

  constructor: ->
    @manager = Grid.DataManager.instance()

  @dataPreview: (table) ->
    Log.blue1 'showing data preview'
    # console.log("%cRendering TABLE", "color: blue;");
    data = @manager.dataForTable(table)
    if data.isEmpty()
      preview = []
    else
      preview = data.preview()
    @constructor.dataForTemplate(preview)

  @columns: (table) ->
    @manager.columnsForTable(table)