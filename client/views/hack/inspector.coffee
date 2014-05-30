class HackInspector extends Grid.Controller
  @include ItemsHelpers
  @template 'hack_inspector'
  helpers: ['isSource', 'isGraph']

class HackInspectorGraph extends Grid.Controller
  @template 'hack_inspector_graph'
  @include ItemsHelpers
  @include Graphing

  helpers: ['sources', 'graphTypeClass']

  actions:
    'click .delete': 'delete'
    'click ul.graph-types li': 'changeType'

  events:
    'change select.source': 'changeSource'

  created: ->

  destroyed: ->
    @comp.stop()

  rendered: ->
    @comp = Deps.autorun =>
      graph = Session.get('selection')
      return unless graph

      @$('select.source').val(graph.sourceId)
      @autoRenderPreview graph,
        $el: @$el
        width: ($el) -> $el.width() - 20
        height: -> 150

  delete: ({_id}) ->
    Graphs.remove(_id)

  changeSource: (e) =>
    Graphs.set(@template.data._id, {sourceId: @$('select.source').val()})

  graphTypeClass: (type) ->
    type = JSON.parse(JSON.stringify(type))
    graph = Graphs.findOne(@template.data._id)
    if graph.type == type
      'selected'
    else
      ''

  changeType: (type) ->
    type = JSON.parse(JSON.stringify(type))
    Graphs.set(@template.data._id, {type: type})
    console.log(@template.data._id, {type: type})

class HackInspectorSource extends Grid.Controller
  @template 'hack_inspector_source'

  actions:
    'blur input': 'saveChanges'
    'click .delete': 'delete'

  rendered: ->
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
