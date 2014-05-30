class HackIndexGroupedTable extends Grid.Controller
  @template 'hack_index_grouped_table'

  constructor: ->
    @manager = Grid.DataManager.instance()

  @groups: (table) ->
    data = @manager.dataForTable(table)
    columns = @manager.columnsForTable(table)

    console.log 'heres data', data

    prepared = for group in data.groups()
      {name: group, columns: columns, data: data.dataForGroup(group).data()}

    console.log 'prepared', prepared

    prepared
  
  # @columns: (table) ->
  #   cols = @manager.columnsForTable(table)
  #   console.log 'here are columns', cols
  #   cols