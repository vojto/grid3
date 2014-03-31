Template.dashboard_show.rendered = ->
  Deps.autorun =>
    data = Router.getData()
    return unless data

    manager = new Grid.SourceManager()

    $chart = $(@find('.graph')).empty()

    graph = Graphs.findOne({sourceId: data._id})
    return unless graph

    data = manager.data(graph)
    grapher = new Grid.Grapher(graph: graph, el: $chart, data: data)

    
Template.dashboard_show.events
  'click button.editor': (e, template) ->
    Router.go 'source.show', @