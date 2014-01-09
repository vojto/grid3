Template['source.show'].rendered = ->
  source = @data
  data = null

  manager = new SourceManager(source)
  manager.loadData ->
    Session.set 'dataPreview', manager.preview()
    data = manager.data

    # Display graph from the data...
    # This code is in the "view section" so it by all means
    # belongs here...

    width = 800
    height = 300

    svg = d3.select('#chart').append('svg')
      .attr('class', 'chart')
      .attr('width', width)
      .attr('height', height+30)

    # Column numbers:
    label = 2
    value = 0

    # Label scale
    labelMin = d3.min data, (d) -> d[label]
    labelMax = d3.max data, (d) -> d[label]
    labelScale = d3.time.scale().domain([labelMin, labelMax]).range([0, width])
    labelAxis = d3.svg.axis().scale(labelScale).orient('bottom')

    # Value scale
    valueMin = d3.min data, (d) -> d[value]
    valueMax = d3.max data, (d) -> d[value]
    valueScale = d3.scale.linear().domain([valueMin, valueMax]).range([height, 0])
    valueAxis = d3.svg.axis().scale(valueScale).orient('right')

    svg.selectAll('circle')
      .data(data)
      .enter()
      .append('circle')
        .attr('r', 3)
        .attr('opacity', 0.8)
        .attr('class', 'point')
        .attr('transform', (d) -> "translate(#{labelScale(d[label])}, #{valueScale(d[value])})")

    svg.append('g')
      .call(valueAxis)

    svg.append('g')
      .attr('transform', "translate(0, #{height})")
      .call(labelAxis)


Template['source.show'].helpers
  dataPreview: ->
    Session.get('dataPreview')

  dataColumns: ->
    preview = Session.get('dataPreview')
    return [] unless preview
    row = preview[0]    
    row.map (col, i) ->
      i + 1