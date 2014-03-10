Template.dashboard_show.rendered = ->
  return unless @data._id

  console.log 'Source: ', @data

  manager = new SourceManager(@data)
  manager.loadData()

  Deps.autorun =>
    $chart = $(@find('.graph')).empty()

    graph = Graphs.findOne({sourceId: @data._id})
    return unless graph

    data = manager.data()
    console.log 'data', data
    grapher = new Grapher(graph: graph, el: $chart, data: data)

    
Template.dashboard_show.events
  'click button.editor': (e, template) ->
    console.log @
    Router.go 'source.show', @