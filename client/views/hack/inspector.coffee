class HackInspector extends Grid.Controller
  @extend ItemsHelpers
  @template 'hack_inspector'

class HackInspectorGraph extends Grid.Controller
  @template 'hack_inspector_graph'
  @include ItemsHelpers
  @include Graphing

  helpers: ['tables', 'graphTypeClass']

  actions:
    'click .delete': 'delete'
    'click ul.graph-types li': 'changeType'

  events:
    'change select.table': 'changeTable'

  created: ->

  destroyed: ->
    @comp.stop()

  rendered: ->
    @comp = Deps.autorun =>
      graph = Session.get('selection')
      return unless graph

      @$('select.table').val(graph.tableId)
      @autoRenderPreview graph,
        $el: @$el
        width: ($el) -> $el.width() - 20
        height: -> 150

  delete: ({_id}) ->
    Graphs.remove(_id)

  changeTable: (e) =>
    Graphs.set(@template.data._id, {tableId: @$('select.table').val()})

  graphTypeClass: (type, graph) ->
    # console.log 'args', arguments
    # console.log 'checking'
    type = JSON.parse(JSON.stringify(type))
    # graph = Session.get('selection')
    if graph.type == type
      'selected'
    else
      ''

  changeType: (type) ->
    $(".graph-types li").removeClass('selected')
    $(".graph-types li.#{type}").addClass('selected')
    type = JSON.parse(JSON.stringify(type))
    Graphs.set(@template.data._id, {type: type})

class HackInspectorTable extends Grid.Controller
  @template 'hack_inspector_table'

  actions:
    'blur input': 'saveChanges'
    'click .delete': 'delete'

  rendered: ->
    $(document).on 'hack.willSelect', =>
      @$('input').blur()

  saveChanges: (table) ->
    data =
      title: @$('input.title').val()
      url: @$('input.url').val()
    Tables.set(table._id, data)

  delete: (table) ->
    Tables.remove(table._id)
    Session.set('selection', null)
