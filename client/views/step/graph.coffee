Template.source_graph.rendered = ->
  manager = null

  # Render the graph whenever source/graph changes
  Deps.autorun =>
    graph = Session.get('editedObject')

    return unless manager
    return unless graph
    step = Steps.findOne({_id: graph.inputStepId})
    # console.log 'getting graph data for step', step
    data = manager.data(step)

    $chart = $(@find('.graph'))
    $chart.empty()

    if !graph || !graph.isGraph
      return

    # Reload the graph from database, to make sure we get 
    # an auto-updating version with deps.
    graph = Graphs.findOne({_id: graph._id})

    grapher = new Grid.Grapher(graph: graph, el: $chart, data: data)
    
    ###
    width = $chart.width()
    height = 400
    svg = d3.select($chart.get(0)).append('svg')
      .attr('class', 'chart')
      .attr('width', width)
      .attr('height', height+30)

    # For now we'll just draw the graph manually.
    # Next step of course is to use the code from
    # graph model.
    label = 0
    value = 1

    # Label scale
    x = d3.time.scale().domain(d3.extent(data, (d) -> d[label])).range([0, width])
    xAxis = d3.svg.axis().scale(x).orient('bottom')
    y = d3.scale.linear().domain(d3.extent(data, (d) -> d[value])).range([height, 0])
    yAxis = d3.svg.axis().scale(y).orient('right')

    svg.append('g').attr('transform', "translate(0, #{height})").call(xAxis)
    svg.append('g').call(yAxis)

    code = "(function(data, svg, x, y) { #{graph.code} })"
    compiled = eval(code)
    compiled(data, svg, x, y)
    ###