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
    return [] unless preview
    row = preview[0]    
    row.map (col, i) ->
      i + 1

  steps: ->
    Steps.find({sourceId: @_id}, {sort: {weight: 1}})

Template.source_show.events
  'click a.add-map': (e) ->
    e.preventDefault()
    console.log 'adding map step'

    step = Steps.findOne({sourceId: @_id}, {sort: {weight: -1}})
    if step
      weight = step.weight + 1
    else
      weight = 0
    

    params =
      sourceId: @_id
      weight: weight
      title: 'Map'
      code: '// `data` is your data file. Manipulate it and return.\nfunction(data) {\n\t\n}'

    Steps.insert params, (e) ->
      console.log 'Finished inserting', e

  'click div.step.collapsed': (e) ->
    console.log @
    @expanded = true

  'keydown textarea': (e) ->
    if e.keyCode == 9
      insertAtCaret(e.currentTarget, '  ')
      e.preventDefault()

  'submit form': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).serializeObject()
    console.log 'data', data
    console.log 'object', @

    Steps.update {_id: @_id}, {$set: data}, (err) ->
      console.log 'err', err

  'click input.delete': (e) ->
    e.preventDefault()
    Steps.remove {_id: @_id}