ItemsHelpers =
  isSource: (item) -> item.collection == 'sources'
  isGraph: (item) -> item.collection == 'graphs'
  sources: -> Sources.find().fetch()
  graphs: -> Graphs.find().fetch()

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

  didRender: ->
    $(document.body).mousedown(@deselect.bind(@))

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


class HackIndexItem extends Grid.Controller
  @template 'hack_index_item'

  helpers: [
    'itemStyle',
    'itemClass',
    'isSource',
    'isGraph'
  ]

  actions:
    'mousedown .item': 'selectItem'

  constructor: ->
    super

  didRender: ->
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

  didRender: ->

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

# Source inspector

class HackInspector extends Grid.Controller
  @include ItemsHelpers
  @template 'hack_inspector'
  helpers: ['isSource', 'isGraph']

class HackInspectorGraph extends Grid.Controller
  @template 'hack_inspector_graph'
  @include ItemsHelpers

  helpers: ['sources']

  actions:
    'click .delete': 'delete'

  events:
    'change select.source': 'changeSource'

  didRender: ->
    graph = @template.data
    @$('select.source').val(graph.sourceId)

    source = Sources.findOne(graph.sourceId)
    return unless source

    console.log 'rendering the graph...'
    manager = Grid.DataManager.instance()
    info = manager.dataForSource(source)
    data = info.data()
    meta = info.metadata()

    index = {x: 0, y: 1}
    domain =
      x: d3.extent(data, (d) -> d[index.x])
      y: d3.extent(data, (d) -> d[index.y])

    console.log 'domains', domain
    # scale =
      # x: 



  delete: ({_id}) ->
    Graphs.remove(_id)

  changeSource: (e) =>
    Graphs.set(@template.data._id, {sourceId: @$('select.source').val()})

class HackInspectorSource extends Grid.Controller
  @template 'hack_inspector_source'

  actions:
    'blur input': 'saveChanges'
    'click .delete': 'delete'

  didRender: ->
    $(document).on 'hack.willSelect', =>
      @$('input').blur()

  saveChanges: (source) ->
    data =
      title: @$('input.title').val()
      url: @$('input.url').val()
    Sources.set(source._id, data)

  delete: (source) ->
    Sources.remove(source._id)
    Session.set('selection', null)
