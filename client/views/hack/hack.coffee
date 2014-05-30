ItemsHelpers =
  isSource: (item) -> item.collection == 'sources'
  isGraph: (item) -> item.collection == 'graphs'
  sources: ->
    Sources.find().fetch()
    # []
  graphs: ->
    Graphs.find().fetch()
    # []

color = d3.scale.category10()

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

Graphing =
  autoRenderPreview: (graph, options) ->
    @renderPreview(graph, options)

    Graphs.find(_id: graph._id).observeChanges 
      changed: (id, fields) =>
        if ('sourceId' of fields) or ('width' of fields) or ('height' of fields)
          # Graph object is not automatically refreshed
          @renderPreview(Graphs.findOne(graph._id), options)

  renderPreview: (graph, {$el, width, height}) ->
    # Refresh the graph
    source = Sources.findOne(graph.sourceId)
    return unless source

    manager = Grid.DataManager.instance()
    info = manager.dataForSource(source)
    data = info.data()
    meta = info.metadata()

    index = {x: 0, y: 1}
    domain =
      x: d3.extent(data, (d) -> d[index.x])
      y: d3.extent(data, (d) -> d[index.y])

    width = width($el) if typeof width == 'function'
    height = height($el) if typeof height == 'function'

    scale =
      x: d3.time.scale().domain(domain.x).range([0, width])
      y: d3.scale.linear().domain(domain.y).range([height, 0])

    line = d3.svg.area()
      .interpolate('basis')  
      .x((d) -> scale.x(d[index.x]) )
      .y1((d) -> scale.y(d[index.y]) )
      .y0(height)

    $el.find('svg').remove()
    el = d3.select($el.get(0))
    svg = el.append('svg')
      .attr('class', 'preview')
      .attr('width', width)
      .attr('height', height)

    svg.append('path')
      .attr('class', 'line')  
      .attr('d', line(data))
      # .style('fill', '#f591f4')
      .style('fill', color(graph._id))
      .style('stroke-width', '0')

class HackIndexGraph extends Grid.Controller
  @template 'hack_index_graph'
  @include Graphing

  didRender: ->
    graph = @template.data
    @$('select.source').val(graph.sourceId)

    @autoRenderPreview graph,
      $el: @$el.find('.content-wrapper')
      width: ($el) -> $el.width()
      height: ($el) -> $el.height()

# Source inspector

class HackInspector extends Grid.Controller
  @include ItemsHelpers
  @template 'hack_inspector'
  helpers: ['isSource', 'isGraph']

class HackInspectorGraph extends Grid.Controller
  @template 'hack_inspector_graph'
  @include ItemsHelpers
  @include Graphing

  helpers: ['sources']

  actions:
    'click .delete': 'delete'

  events:
    'change select.source': 'changeSource'

  didRender: ->
    graph = @template.data
    @$('select.source').val(graph.sourceId)

    @autoRenderPreview graph,
      $el: @$el
      width: ($el) -> $el.width() - 20
      height: -> 150

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
