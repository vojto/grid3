Template.dashboard_show.rendered = ->
  return unless @data._id

  manager = new Grid.SourceManager(@data)
  manager.loadData()

  Deps.autorun =>
    $chart = $(@find('.graph')).empty()

    graph = Graphs.findOne({sourceId: @data._id})
    return unless graph

    data = manager.data()
    grapher = new Grapher(graph: graph, el: $chart, data: data)

    
Template.dashboard_show.events
  'click button.editor': (e, template) ->
    Router.go 'source.show', @