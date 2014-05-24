class HackIndex extends Grid.Controller
  helpers: [
    'sources',
    'selection'
  ]

  actions:
    'click .add-source': 'addSource'

  constructor: ->
    super

  didRender: ->
    $(document.body).mousedown(@deselect.bind(@))

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

  # Working with selection

  deselect: (e) ->
    if e.target == $('div.sources').get(0)
      $('input').blur()
      Session.set('selection', null)

  selection: ->
    Session.get('selection')


class HackIndexSource extends Grid.Controller
  helpers: [
    'sourceStyle',
    'sourceClass',
    'dataPreview',
    'columns'
  ]

  actions:
    'mousedown .source': 'selectSource'

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


  # Previews

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


  # Handling selection

  selectSource: (source) ->
    console.log 'selecting source'
    $(document).trigger('hack.willSelect')
    Session.set('selection', source)

  sourceClass: (source) ->
    selection = Session.get('selection')
    if selection && selection._id == source._id
      'selected'
    else
      ''

# Source inspector

class HackInspectorSource extends Grid.Controller
  template: 'hack_inspector_source'

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


main = new HackIndex(Template.hack_index)
source = new HackIndexSource(Template.hack_index_source)
new HackInspectorSource