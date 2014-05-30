color = d3.scale.category10()

@Graphing =
  autoRenderPreview: (graph, options) ->
    @renderPreview(graph, options)

    @query.stop() if @query
    @query = Graphs.find(_id: graph._id).observeChanges 
      changed: (id, fields) =>
        if ('sourceId' of fields) or ('width' of fields) or ('height' of fields) or ('type' of fields)
          # Graph object is not automatically refreshed
          @renderPreview(Graphs.findOne(graph._id), options)

  renderPreview: (graph, {$el, width, height}) ->
    # Refresh the graph
    source = Sources.findOne(graph.sourceId)
    return unless source

    manager = Grid.DataManager.instance()
    info = manager.dataForSource(source)
    data = info.data()
    meta = info.metadata()

    index = @index = {x: 0, y: 1}
    domain = @domain =
      x: d3.extent(data, (d) -> d[index.x])
      y: d3.extent(data, (d) -> d[index.y])

    margin = @margin =
      top: 10
      right: 0
      bottom: 20
      left: 40

    outerWidth = width($el) if typeof width == 'function'
    outerHeight = height($el) if typeof height == 'function'

    return if outerWidth < 0

    width = outerWidth - margin.left - margin.right
    height = outerHeight - margin.top - margin.bottom

    size = @size = {width: width, height: height}

    scale = @scale =
      x: d3.time.scale().domain(domain.x).range([0, width])
      y: d3.scale.linear().domain(domain.y).range([height, 0])

    $el.find('svg').remove()
    el = d3.select($el.get(0))
    svg = el.append('svg')
      .attr('class', 'preview')
      .attr('width', outerWidth)
      .attr('height', outerHeight)
      .append('g')
        .attr('transform', "translate(#{margin.left}, #{margin.top})")

    svg.call(@addAxes, @scale, @size)

    color2 = color(graph._id)
    if graph.type == 'area'
      @renderAreaChart(svg, data: data, color: color)
    else if graph.type == 'bar'
      @renderBarChart(svg, data: data, color: color2)

  addAxes: (svg, scale, size) ->
    axis =
      x: d3.svg.axis().scale(scale.x).orient('bottom')
      y: d3.svg.axis().scale(scale.y).orient('left')

    svg.append('g')
      .attr('class', 'axis')
      .attr('transform', "translate(0, #{size.height+1})")
      .call(axis.x)

    svg.append('g')
      .attr('class', 'axis')
        .attr('transform', "translate(-1, 0)")
      .call(axis.y)

  renderAreaChart: (svg, {data}) ->
    {size, scale, index} = @

    line = d3.svg.area()
      .interpolate('basis')  
      .x((d) -> scale.x(d[index.x]) )
      .y1((d) -> scale.y(d[index.y]) )
      .y0(size.height)

    svg.append('path')
      .attr('class', 'line')  
      .attr('d', line(data))
      # .style('fill', '#f591f4')
      .style('fill', color)
      .style('stroke-width', '0')

  renderBarChart: (svg, {data, color}) ->
    {size, scale, index} = @

    domain = scale.x.domain()

    maxDay = new Date(domain[1])
    maxDay.setDate(maxDay.getDate() + 1)
    buckets = d3.time.days(domain[0], maxDay)

    # console.log 'buckets', buckets

    x = d3.scale.ordinal().domain(buckets).rangeRoundBands([0, size.width], .1)

    bar = svg.selectAll('.bar')
      .data(data)

    bar.enter().append('rect')
      .attr('class', 'bar')
      .attr('x', (d) -> x(d[index.x]))
      .attr('width', (d) -> x.rangeBand())
      .attr('y', (d) -> scale.y(d[index.y]))
      .attr('height', (d) -> size.height - scale.y(d[index.y]))
      .attr('fill', color)
