class Grid.Grapher
  constructor: (options) ->
    @graph = options.graph
    @$el = options.el
    @data = options.data
    data = @data

    width = @$el.width()
    height = 300
    svg = d3.select(@$el.get(0)).append('svg')
      .attr('class', 'chart')
      .attr('width', width+30)
      .attr('height', height+40)

    label = 0
    value = 1

    # Label scale
    # x = d3.scale.linear().domain(d3.extent(data, (d) -> d[label])).range([0, width])
    domain = d3.extent(data, (d) -> d[label])
    x = d3.time.scale().domain(domain).range([40, width-30])
    xAxis = d3.svg.axis().scale(x).orient('bottom')
    domain = @addMarginToDomain(d3.extent(data, (d) -> d[value]))
    y = d3.scale.linear().domain(domain).range([height, 0])
    yAxis = d3.svg.axis().scale(y).orient('left')

    svg.append('g').attr('transform', "translate(0, #{height})").call(xAxis)
    svg.append('g').attr('transform', "translate(40, 0)").call(yAxis)

    code = "(function(data, svg, x, y) { #{@graph.code} })"
    compiled = eval(code)
    compiled(data, svg, x, y)
  
  addMarginToDomain: (domain) ->
    size = Math.abs(domain[1] - domain[0])
    margin = size * 0.1
    return [domain[0] - margin, domain[1] + margin]