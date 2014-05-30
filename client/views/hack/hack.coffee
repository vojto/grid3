@ItemsHelpers =
  isSource: (item) ->
    item.collection == 'sources'
  isGraph: (item) ->
    item.collection == 'graphs'
  sources: ->
    Sources.find().fetch()
    # []
  graphs: ->
    Graphs.find().fetch()
    # []

class HackIndex extends Grid.Controller
  @template 'hack_index'
  @include ItemsHelpers

  helpers: [
    'sources',
    'graphs',
    'selection'
  ]

  actions:
    'click .add-source': 'addSource'
    'click .add-graph': 'addGraph'

  constructor: ->
    super

  rendered: ->
    $(document.body).mousedown(@deselect.bind(@))

    Mousetrap.bind 'backspace', (e) =>
      e.preventDefault()
      @deleteSelected()
      false

  addSource: ->
    width = $(document).width()
    height = $(document).height()
    Sources.insert({
      title: 'New source',
      width: 230,
      height: 180,
      x: _.random(10, width-250),
      y: _.random(50, height-200)
    })

  addGraph: ->
    width = $(document).width()
    height = $(document).height()
    Graphs.insert({
      title: 'New graph',
      width: 280,
      height: 160,
      x: _.random(10, width-250),
      y: _.random(50, height-200)
    })


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
      Sources.remove(item._id)
      Graphs.remove(item._id)
    Session.set('selection', null)


class HackIndexItem extends Grid.Controller
  @template 'hack_index_item'

  helpers: [
    'itemStyle',
    'itemClass',
    'isSource',
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

    Sources.set id, {x: x, y: y, width: width, height: height}
    Graphs.set id, {x: x, y: y, width: width, height: height}

  itemStyle: (source) ->
    "left: #{source.x||10}px; top: #{source.y||60}px; width: #{source.width||200}px; height: #{source.height||100}px; "

  # Types of items

  isSource: (item) -> item.collection == 'sources'
  isGraph: (item) -> item.collection == 'graphs'

  # Handling selection

  selectItem: (item) ->
    $(document).trigger('hack.willSelect')
    Session.set('selection', item)

  itemClass: (source) ->
    selection = Session.get('selection')
    if selection && selection._id == source._id
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

  dataPreview: (source) ->
    data = @dataManager.dataForSource(source)
    if data.isEmpty()
      preview = for i in [0..6]
        ['&nbsp;', '&nbsp;', '&nbsp;']
    else
      preview = data.preview()

    mapped = _(preview).map (row, i) ->
      row = _(row).map (cell, j) ->
        {index: j, cell: cell}
      {index: i, row: row}

    mapped

  columns: (source) ->
    data = @dataManager.dataForSource(source)
    if data.isEmpty()
      ['A', 'B', 'C']
    else

      data.columns()

class HackIndexGraph extends Grid.Controller
  @template 'hack_index_graph'
  @include Graphing

  rendered: ->
    graph = @template.data
    @$('select.source').val(graph.sourceId)

    @autoRenderPreview graph,
      $el: @$el.find('.content-wrapper')
      width: ($el) -> $el.width()
      height: ($el) -> $el.height()

