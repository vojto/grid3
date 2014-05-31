class HackIndexGroupedTable extends Grid.Controller
  @template 'hack_index_grouped_table'
  @include DataHelpers

  constructor: ->
    @manager = Grid.DataManager.instance()

  @groups: (table) ->
    console.log("%cRendering GROUPED TABLE", "color: blue;");

    data = @manager.dataForTable(table)
    columns = @manager.columnsForTable(table)


    prepared = for group in data.groups()
      dataForTemplate = @dataForTemplate(data.dataForGroup(group).data())
      {name: group, columns: columns, data: dataForTemplate}

    prepared
  
  # @columns: (table) ->
  #   cols = @manager.columnsForTable(table)
  #   console.log 'here are columns', cols
  #   cols