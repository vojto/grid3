class Grid.Grapher
  constructor: (options) ->
    @graph = options.graph
    @$el = options.el
    @data = options.data
    data = @data

    width = @$el.width()
    height = 400
    svg = d3.select(@$el.get(0)).append('svg')
      .attr('class', 'chart')
      .attr('width', width)
      .attr('height', height+30)

    label = 0
    value = 1

    # Label scale
    # x = d3.scale.linear().domain(d3.extent(data, (d) -> d[label])).range([0, width])
    x = d3.time.scale().domain(d3.extent(data, (d) -> d[label])).range([0, width])
    xAxis = d3.svg.axis().scale(x).orient('bottom')
    y = d3.scale.linear().domain(d3.extent(data, (d) -> d[value])).range([height, 0])
    yAxis = d3.svg.axis().scale(y).orient('right')

    svg.append('g').attr('transform', "translate(0, #{height})").call(xAxis)
    svg.append('g').call(yAxis)

    code = "(function(data, svg, x, y) { #{@graph.code} })"
    compiled = eval(code)
    compiled(data, svg, x, y)