Template.dashboard_show.rendered = ->
  Deps.autorun =>
    project = Router.getData()
    return unless project

    manager = new Grid.SourceManager()

    $chart = $(@find('.graph')).empty()

    graphs = Graphs.find({projectId: project._id}).fetch()

    for graph in graphs
      $el = $('<div />').appendTo($chart)
      data = manager.data(graph)
      grapher = new Grid.Grapher(
        graph: graph,
        el: $el,
        data: data
      )

    
Template.dashboard_show.events
  'click button.editor': (e, template) ->
    Router.go 'flow.edit', @