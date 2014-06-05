class HackIndex extends Grid.Controller
  @template 'hack_index'
  @extend ItemsHelpers

  helpers: [
    'tables',
    'graphs',
    'selection'
  ]

  actions:
    'click .toolbar .add-source': 'addSource'
    'click .toolbar .add-graph': 'addGraph'
    'click .toolbar .group': 'addGroupTable'
    'click .toolbar .add-aggregation': 'addAggregationTable'

  constructor: ->
    super

  rendered: ->
    $(document.body).mousedown(@deselect.bind(@))

    Mousetrap.bind 'backspace', (e) =>
      e.preventDefault()
      @deleteSelected()
      false

  addSource: ->
    # Display selector for the type of data source
    modal = Modal.show(template: 'hack_modal_source_selector')
    setTimeout =>
      $('.dialog li').click =>
        $('.modal').remove()
        options = @defaultTableOptions()
        options.title = 'New source'
        options.type = 'source'
        options.columnIds = []
        Tables.insert(options)
    , 0

  addGraph: ->
    options = @defaultTableOptions(280, 160)
    options.tableId = Session.get('selection')?._id
    options.title = 'New graph'
    Graphs.insert(options)

  addGroupTable: ->
    options = @defaultTableOptions()
    options.title = 'New group table'
    options.type = Tables.GROUPED
    current = Session.get('selection')
    if current.type != Tables.SOURCE
      alert('Cannot group data from this table')
      return
    
    options.inputTableId = current._id
    Tables.insert(options)

  addAggregationTable: ->
    options = @defaultTableOptions()
    options.title = 'New aggregation table'
    options.type = Tables.AGGREGATION
    current = Session.get('selection')
    if current.type != Tables.GROUPED
      return alert('Cannot aggregate data from this table')

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
  @extend ItemsHelpers

  helpers: [
    'itemStyle',
    'itemClass',
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
  @extend DataHelpers

  helpers: [
    'columns'
  ]

  # Previews

  constructor: ->
    super
    @dataManager = Grid.DataManager.instance()

  rendered: ->

  @dataPreview: (table) ->
    data = @dataManager.dataForTable(table)
    if data.isEmpty()
      preview = []
    else
      preview = data.preview()
    @constructor.dataForTemplate(preview)

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


class Select extends Grid.Controller
  @template 'select'

  actions:
    'change select': 'change'

  @optionAttributes: (option) ->
    {doc, value, options, field} = @template.data

    if option[value] == doc[field]
      {"selected": "", value: option[value]}
    else
      {value: option[value]}

  @optionLabel: (option) ->
    {label} = @template.data
    option[label]

  change: ->
    val = @el.val()
    {collection, doc, value, options, field, prompt} = @template.data
    collection = window[collection]

    val = null if val == '' or val == prompt

    # if val
    data = {}
    data[field] = val
    collection.set(doc._id, data)
    # else



