Template.source_graph.rendered = ->
  # Cancel if data (source) didn't come through from router yet
  return unless @data._id

  # Prepare the source manager
  manager = new SourceManager(@data)
  manager.loadData()

  # Put data into preview whenever source/steps change
  Deps.autorun =>
    Session.set 'preview', manager.preview()

  # Render the graph whenever source/graph changes
  Deps.autorun =>
    data = manager.data()
    if !(data instanceof Array)
      data2 = Object.keys(data).map (k) ->
        [parseFloat(k), data[k]]
      data = data2


    $chart = $(@find('.graph'))
    # console.log 'heres the $chart', $chart
    $chart.empty()

    graph = Session.get('editedObject')
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
    x = d3.scale.linear().domain(d3.extent(data, (d) -> d[label])).range([0, width])
    xAxis = d3.svg.axis().scale(x).orient('bottom')
    y = d3.scale.linear().domain(d3.extent(data, (d) -> d[value])).range([height, 0])
    yAxis = d3.svg.axis().scale(y).orient('right')

    svg.append('g').attr('transform', "translate(0, #{height})").call(xAxis)
    svg.append('g').call(yAxis)

    code = "(function(data, svg, x, y) { #{graph.code} })"
    compiled = eval(code)
    compiled(data, svg, x, y)

    # line = d3.svg.line().interpolate('basis')
    #   .x((d) -> x(d[label]))
    #   .y((d) -> y(d[value]))
    # svg.append('path')
    #   .attr('class', 'line')
    #   .attr('d', line(data))


    # line = d3.svg.line().interpolate('basis')
    #   .x((d) -> x(d[label]))
    #   .y((d) -> y(d[value]))
    # svg.append('path')
    #   .attr('class', 'line')
    #   .attr('d', line(data))