Template.source_graph.rendered = ->
  manager = null

  # Put data into preview whenever source/steps change
  Deps.autorun =>
    data = Router.getData()
    return unless data
    manager = new Grid.SourceManager(data)
    manager.loadData()
    edited = Session.get('editedObject')
    Session.set 'preview', manager.preview(edited)

  # Render the graph whenever source/graph changes
  Deps.autorun =>
    graph = Session.get('editedObject')

    return unless manager
    data = manager.data(graph)

    $chart = $(@find('.graph'))
    $chart.empty()

    if !graph || !graph.isGraph
      return

    # Reload the graph from database, to make sure we get 
    # an auto-updating version with deps.
    graph = Graphs.findOne({_id: graph._id})
    
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
    console.log 'code', code
    compiled = eval(code)
    console.log 'compiled', compiled
    compiled(data, svg, x, y)