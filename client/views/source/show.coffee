Template.source_show.rendered = ->
  source = @data
  data = null

  manager = new SourceManager(source)
  manager.loadData ->
    Session.set 'dataPreview', manager.preview()
    data = manager.data()

    # Display graph from the data...
    # This code is in the "view section" so it by all means
    # belongs here...

    return

    width = 800
    height = 300

    $('#chart').empty()
    svg = d3.select('#chart').append('svg')
      .attr('class', 'chart')
      .attr('width', width)
      .attr('height', height+30)

    # Column numbers:
    label = data.config.label
    value = data.config.value

    data = data.parse()

    # Label scale
    labelMin = d3.min data, (d) -> d[label]
    labelMax = d3.max data, (d) -> d[label]
    console.log labelMin, labelMax
    labelScale = d3.time.scale().domain([labelMin, labelMax]).range([0, width])
    labelAxis = d3.svg.axis().scale(labelScale).orient('bottom')

    # Value scale
    valueMin = d3.min data, (d) -> d[value]
    valueMax = d3.max data, (d) -> d[value]
    valueScale = d3.scale.linear().domain([valueMin, valueMax]).range([height, 0])
    valueAxis = d3.svg.axis().scale(valueScale).orient('right')

    # Dots
    svg.selectAll('circle')
      .data(data)
      .enter()
      .append('circle')
        .attr('r', 3)
        .attr('opacity', 0.8)
        .attr('class', 'point')
        .attr('transform', (d) -> "translate(#{labelScale(d[label])}, #{valueScale(d[value])})")

    # Line
    line = d3.svg.line().interpolate('basis')
      .x((d) -> labelScale(d[label]))
      .y((d) -> valueScale(d[value]))
    svg.append('path')
      .attr('class', 'line')
      .attr('d', line(data))

    # Axes
    svg.append('g')
      .call(valueAxis)

    svg.append('g')
      .attr('transform', "translate(0, #{height})")
      .call(labelAxis)


Template.source_show.helpers
  dataPreview: ->
    Session.get('dataPreview')

  dataColumns: ->
    preview = Session.get('dataPreview')
    console.log 'getting them columns', preview
    return [] unless preview
    row = preview[0]    
    row.map (col, i) ->
      i + 1