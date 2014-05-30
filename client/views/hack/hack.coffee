@ItemsHelpers =
  isSource: (item) ->
    item.collection == 'tables' && item.type == Tables.SOURCE
  isGraph: (item) ->
    item.collection == 'graphs'
  isGroupedTable: (item) ->
    item.collection == 'tables' && item.type == Tables.GROUPED
  tables: ->
    Tables.find().fetch()
  graphs: ->
    Graphs.find().fetch()

class HackIndex extends Grid.Controller
  @template 'hack_index'
  @include ItemsHelpers

  helpers: [
    'tables',
    'graphs',
    'selection'
  ]

  actions:
    'click .toolbar .add-source': 'addSource'
    'click .toolbar .add-graph': 'addGraph'
    'click .toolbar .group': 'addGroupTable'

  constructor: ->
    super

  rendered: ->
    $(document.body).mousedown(@deselect.bind(@))

    Mousetrap.bind 'backspace', (e) =>
      e.preventDefault()
      @deleteSelected()
      false

  addSource: ->
    options = @defaultTableOptions()
    options.title = 'New source'
    options.type = 'source'
    options.columnIds = []
    Tables.insert(options)

  addGraph: ->
    options = @defaultTableOptions(280, 160)
    options.title = 'New graph'
    Graphs.insert(options)

  addGroupTable: ->
    options = @defaultTableOptions()
    options.title = 'New group table'
    options.type = Tables.GROUPED
    current = Session.get('selection')
    if current.type != 'source'
      alert('Cannot group data from this table')
      return
    
    options.inputTableId = current._id
    Tables.insert(options)


  defaultTableOptions: (width=230, height=180) ->
    width = $(document).width()
    height = $(document).height()
    return {
      width: 280,
      height: 160,
      x: _.random(10, width-250),
      y: _.random(50, height-200)
    }

  # Working with selection

  deselect: (e) ->
    if e.target == $('div.items').get(0)
      $('input').blur()
      Session.set('selection', null)

  selection: ->
    Session.get('selection')

  deleteSelected: ->
    item = Session.get('selection')
    if item
      Tables.remove(item._id)
      Graphs.remove(item._id)
    Session.set('selection', null)


class HackIndexItem extends Grid.Controller
  @template 'hack_index_item'
  @include ItemsHelpers

  helpers: [
    'itemStyle',
    'itemClass',
    'isSource',
    'isGroupedTable',
    'isGraph',
    'controllerId'
  ]

  actions:
    'mousedown .item': 'selectItem'
    'click .handle': 'showInfo'

  controllerId: ->
    @_id

  constructor: ->
    super

  rendered: ->
    $(@template.firstNode).draggable(stop: @didStopDragging, handle: '.handle')
    $(@template.firstNode).resizable(stop: @didStopDragging)

  # Dragging

  didStopDragging: (ev) =>
    $el = $(ev.target)
    id = $el.attr('data-id')
    pos = $el.position()
    x = pos.left
    y = pos.top
    width = $el.outerWidth()
    height = $el.outerHeight()

    Tables.set id, {x: x, y: y, width: width, height: height}
    Graphs.set id, {x: x, y: y, width: width, height: height}

  itemStyle: (table) ->
    "left: #{table.x||10}px; top: #{table.y||60}px; width: #{table.width||200}px; height: #{table.height||100}px; "

  # Handling selection

  selectItem: (item) ->
    $(document).trigger('hack.willSelect')
    Session.set('selection', item)

  itemClass: (table) ->
    selection = Session.get('selection')
    if selection && selection._id == table._id
      'selected'
    else
      ''

class HackIndexSource extends Grid.Controller
  @template 'hack_index_source'

  helpers: [
    'dataPreview',
    'columns',
  ]

  # Previews

  constructor: ->
    super
    @dataManager = Grid.DataManager.instance()

  rendered: ->

  dataPreview: (table) ->
    data = @dataManager.dataForTable(table)
    if data.isEmpty()
      preview = []
    else
      preview = data.preview()

    mapped = _(preview).map (row, i) ->
      row = _(row).map (cell, j) ->
        {index: j, cell: cell}
      {index: i, row: row}

    mapped

  columns: (table) ->
    @dataManager.columnsForTable(table)

class HackIndexGraph extends Grid.Controller
  @template 'hack_index_graph'
  @include Graphing

  rendered: ->
    graph = @template.data
    @$('select.table').val(graph.tableId)

    @autoRenderPreview graph,
      $el: @$el.find('.content-wrapper')
      width: ($el) -> $el.width()
      height: ($el) -> $el.height()

