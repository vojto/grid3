class HackIndex extends Grid.Controller
  helpers: [
    'sources'
  ]

  actions:
    'click .add-source': 'addSource'

  constructor: ->
    super

  sources: ->
    Sources.find().fetch()

  addSource: ->
    console.log 'adding source heres el', @$el
    width = $(document).width()
    height = $(document).height()
    Sources.insert({
      title: 'New source',
      width: 230,
      height: 180,
      x: _.random(10, width-250),
      y: _.random(50, height-200)
    })

class HackIndexSource extends Grid.Controller
  helpers: [
    'sourceStyle',
    'dataPreview'
    'columns'
  ]

  constructor: ->
    super
    @dataManager = Grid.DataManager.instance()

  didRender: ->
    $(@template.firstNode).draggable(stop: @didStopDragging, handle: '.handle')
    $(@template.firstNode).resizable(stop: @didStopDragging)

  didStopDragging: (ev) =>
    $el = $(ev.target)
    id = $el.attr('data-id')
    pos = $el.position()
    x = pos.left
    y = pos.top
    width = $el.outerWidth()
    height = $el.outerHeight()

    Sources.set id, {x: x, y: y, width: width, height: height}

  sourceStyle: (source) ->
    "left: #{source.x||10}px; top: #{source.y||60}px; width: #{source.width||200}px; height: #{source.height||100}px; "

  dataPreview: (source) ->
    data = @dataManager.dataForSource(source)
    data.preview()

  columns: (source) ->
    data = @dataManager.dataForSource(source)
    data.columns()    


main = new HackIndex(Template.hack_index)
source = new HackIndexSource(Template.hack_index_source)