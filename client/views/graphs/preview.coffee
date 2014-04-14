class GraphPreview extends Grid.Controller
  didRender: ->
    manager = new Grid.SourceManager()

    # Render the graph whenever source/graph changes
    Deps.autorun =>
      graph = Router.getData().graph

      return unless manager
      return unless graph

      # TODO: In the future, there will be some kind of caching mechanism,
      # that will just stored processed data in the tables collection.
      # TODO: This code should be refactored somewhere into SourceManager
      # or some model class.
      # TODO: This should also support taking data out of a table without any
      # processing steps, so take data directly from the source.
      table = Tables.findOne(graph.tableId)
      return unless table
      lastStepId = _.last(table.stepIds)
      step = Steps.findOne(lastStepId)

      return unless step
      data = manager.data(step)

      $chart = $(@template.find('.graph'))
      $chart.empty()

      # Reload the graph from database, to make sure we get 
      # an auto-updating version with deps.
      graph = Graphs.findOne({_id: graph._id})

      grapher = new Grid.Grapher(graph: graph, el: $chart, data: data)

new GraphPreview(Template.graph_preview)