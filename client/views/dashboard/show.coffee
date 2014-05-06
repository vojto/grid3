dashboard = ->
  console.log('rendering dashboard')

  # Current
  # data = Grid.Loader.loadUrl(url)
  caloriesUrl = 'http://rinik.net/data/calories.csv'
  Meteor.call 'sources.loadUrl', caloriesUrl, (err, data) ->
    weightUrl = 'http://rinik.net/data/temple.csv'
    Meteor.call 'sources.loadUrl', weightUrl, (err, weightData) ->
      data.splice(0, 1)
      data = data.map (d) -> [moment(d[0]), parseFloat(d[1])]
      data = data.filter (d) ->
        d[0].diff(moment(), 'days') != -1
      data = data.map (d) -> [d[0].toDate(), d[1]]
      weightData.splice(0, 1)
      weightData = weightData.map (d) -> [moment(d[0]).toDate(), parseFloat(d[1])]

      # Should be wrapper in something like:
      # vis = dashboard.addVis('100%x300')
      $el = $('.dashboard')
      width = $el.width()
      height = 300

      # Scales
      domain = d3.extent(data, (d) -> d[0])
      x = d3.time.scale().domain(domain).range([40, width-20])
      
      domain = d3.extent(data, (d) -> d[1])
      y = d3.scale.linear().domain(domain).range([height-40, 0])
      weightDomain = d3.extent(weightData, (d) -> d[1])
      y2 = d3.scale.linear().domain([197, 217]).range([height-40, 0])
      yAxis = d3.svg.axis().scale(y2).orient('left')

      svg = d3.select($el.get(0)).append('svg')
        .attr('class', 'chart')
        .attr('width', width)
        .attr('height', height)
        .style('background', '#fff')

      
      svg.append('g').attr('transform', "translate(40, 0)").call(yAxis)

      red = '#ffaaaa'
      green = '#bcffaa'
      yellow = '#faffaa'
      orange = '#ffe2aa'
      greenToYellow = d3.scale.linear().domain([2500, 3000]).range([green, yellow])
      yellowToOrange = d3.scale.linear().domain([3000, 3500]).range([yellow, orange])

      barWidth = Math.round(width/data.length)
      svg.selectAll('rect')
        .data(data)
        .enter()
        .append('rect')
        .attr('width', barWidth)
        .attr('height', height-40)
        .attr('x', (d) -> x(d[0]) )
        .attr('y', (d) -> 0 )
        .style 'fill', (d) ->
          if d[1] < 2000
            red # Cheat
          else if d[1] < 2500
            green
          else if d[1] < 3000
            greenToYellow(d[1])
          else if d[1] < 3500
            yellowToOrange(d[1])
          else
            red

      line = d3.svg.line()
        .interpolate('basis')  
        .x((d) -> x(d[0]) )
        .y((d) -> y2(d[1]) )

      svg.append('path')
          .attr('class', 'line')  
          .attr('d', line(weightData))
          .style('fill', 'none')
          .style('stroke', '#000')
          .style('stroke-width', '2')

      svg.selectAll('circle')
        .data(weightData)
        .enter()
        .append('circle')
        .attr 'cx', (d) -> x(d[0])
        .attr 'cy', (d) -> y2(d[1])
        .attr 'r', 3
        .style 'fill', 'none'
        .style 'stroke', '#000'
        .style 'stroke-width', '2'

      xAxis = d3.svg.axis().scale(x).orient('bottom').tickFormat(d3.time.format('%m/%d')).ticks(4)
      svg.append('g').attr('transform', "translate(0, #{height-40})").call(xAxis)


Template.dashboard_show.rendered = ->
  Deps.autorun =>
    project = Router.getData()
    return unless project

    dashboard()


    
Template.dashboard_show.events
  'click button.editor': (e, template) ->
    Router.go 'flow.edit', @