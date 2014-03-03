manager = null

# Template.source_show.created = ->

Template.source_show.rendered = ->
  return unless @data._id

  manager = new SourceManager(@data)
  manager.loadData()

  # Put data into preview whenever source/steps change
  Deps.autorun =>
    Session.set 'preview', manager.preview()

  # Render the graph whenever source/graph changes
  Deps.autorun =>
    data = Session.get('preview')
    if !(data instanceof Array)
      data2 = Object.keys(data).map (k) ->
        [parseFloat(k), data[k]]
      data = data2


    $chart = $(@find('.chart'))
    $chart.empty()
    # Prepare the graph model
    graph = Graphs.findOne(sourceId: @data._id)
    return unless graph
    
    width = $chart.width()
    height = $chart.height()
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
    
Template.source_show.helpers
  dataColumns: ->
    preview = Session.get('preview')
    return [] unless preview
    row = preview[0]    
    row.map (col, i) ->
      i + 1

  steps: ->
    console.log 'getting steps for source', @
    Steps.forSource(@)

  graphs: ->
    Graphs.forSource(@)

Template.source_show.events
  # General

  'keydown textarea': (e) ->
    if e.keyCode == 9
      insertAtCaret(e.currentTarget, '  ')
      e.preventDefault()

  # Steps

  'click .action.add-step': (e) ->
    e.preventDefault()

    params =
      sourceId: @_id
      weight: Steps.nextWeight(@)
      title: 'Map'
      code: Steps.DEFAULT_CODE

    Steps.insert params, Flash.handle

  'click div.step.collapsed': (e) ->
    Steps.set(@_id, expanded: true)

  'submit form.step': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).serializeObject()
    data.expanded = false
    Steps.set(@_id, data, Flash.handle)

  'click input.delete-step': (e) ->
    e.preventDefault()
    Steps.remove {_id: @_id}

  # Graphs

  'click .action.add-graph': (e) ->
    e.preventDefault()
    Graphs.insert {sourceId: @_id, title: 'Viz', code: '//'}, Flash.handle

  'click div.graph.collapsed': (e) ->
    Graphs.set(@_id, {expanded: true}, Flash.handle)

  'submit form.graph': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).serializeObject()
    data.expanded = false
    Graphs.set(@_id, data, Flash.handle)

  'click input.delete-graph': (e) ->
    e.preventDefault()
    Graphs.remove({_id: @_id}, Flash.handle)