class HackIndexGroupedTable extends Grid.Controller
  @template 'hack_index_grouped_table'
  @include DataHelpers

  events:
    'click .header': 'toggleGroup'

  constructor: ->
    @manager = Grid.DataManager.instance()

  @groups: (table) ->
    # console.log("%cRendering GROUPED TABLE", "color: blue;");

    data = @manager.dataForTable(table)
    columns = @manager.columnsForTable(table)


    prepared = for group in data.groups()
      groupData = data.dataForGroup(group).data()
      previewSize = 3
      groupPreview = _(groupData).head(previewSize)
      if groupData.length > previewSize
        more = groupData.length - previewSize
      
      # Show only a small preview of data here
      dataForTemplate = @dataForTemplate(groupPreview)
      {name: group, columns: columns, data: dataForTemplate, more: more}

    prepared

  toggleGroup: (ev) ->
    $header = $(ev.currentTarget).closest('.header')
    $group = $header.closest('.group')
    $group.toggleClass('expanded')
  
  # @columns: (table) ->
  #   cols = @manager.columnsForTable(table)
  #   console.log 'here are columns', cols
  #   cols