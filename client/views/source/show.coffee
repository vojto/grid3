manager = null

# TODO: This code belongs to the model

LINE_CHART_CODE = """
var line = d3.svg.line()
    .interpolate('basis')  
    .x(function(d) { return x(d[0]) })
    .y(function(d) { return y(d[1]) });

svg.append('path')
    .attr('class', 'line')  
    .attr('d', line(data));
"""

BAR_CHART_CODE = """
var width = svg.attr('width') / data.length;
var barWidth = width;
var height = svg.attr('height');

svg.selectAll('rect')
  .data(data)
  .enter()
  .append('rect')
  .attr('width', barWidth)
  .attr('height', function(d) { return height-y(d[1])-30 })
  .attr('x', function(d) { return x(d[0]) })
  .attr('y', function(d) { return y(d[1]) });
"""
    
Template.source_show.helpers
  dataColumns: ->
    preview = Session.get('preview')
    return [] unless preview
    row = preview[0]    
    row.map (col, i) ->
      i + 1

  steps: ->
    Steps.forSource(@)

  graphs: ->
    Graphs.forSource(@)

  currentClass: ->
    edited = Session.get('editedObject')
    if edited && edited._id == @_id
      'edited'
    else
      ''
  
  plusButton: (klass, icon, label) ->
    "<div class='step action #{klass}'><i class='entypo #{icon}'></i><span>#{label}</span></div>"
    

Template.source_show.events
  # General

  'keydown textarea': (e) ->
    if e.keyCode == 9
      insertAtCaret(e.currentTarget, '  ')
      e.preventDefault()

  'click a.flow': (e) ->
    e.preventDefault()
    Router.go('flow.edit', @)

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
    Session.set('editedObject', @)

  # Graphs

  'click .action.add-line-chart': (e) ->
    e.preventDefault()
    Graphs.insert {sourceId: @_id, title: 'Viz', code: LINE_CHART_CODE}, Flash.handle

  'click .action.add-bar-chart': (e) ->
    e.preventDefault()
    Graphs.insert {sourceId: @_id, title: 'Viz', code: BAR_CHART_CODE}, Flash.handle

  'click div.graph.collapsed': (e) ->
    Graphs.set(@_id, {expanded: true}, Flash.handle)

  'click input.delete-graph': (e) ->
    e.preventDefault()
    Graphs.remove({_id: @_id}, Flash.handle)