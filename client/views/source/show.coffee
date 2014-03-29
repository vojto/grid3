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
    
# This snippet selects "any" step in case that no step is selected
# and we're not on any branch.
Template.source_show.rendered = ->
  Deps.autorun ->
    source = Router.getData()
    return unless source

    selectedStep = Session.get('selectedStep')
    if !selectedStep
      step = Steps.lastForSource(source)
      Session.set('selectedStep', step)

Template.source_show.helpers
  dataColumns: ->
    preview = Session.get('preview')
    return [] unless preview
    row = preview[0]    
    row.map (col, i) ->
      i + 1

  steps: ->
    # This is based on the editedObject now.
    selected = Session.get('selectedStep')
    return [] unless selected

    steps = Steps.stepsUpUntil(selected)

    # Find all following steps
    next = selected
    while next = Steps.findStepOrGraphBy({inputStepId: next._id})
      steps.push(next)

    # Return result
    steps

  currentClass: ->
    edited = Session.get('editedObject')
    if edited && edited._id == @_id
      'edited'
    else
      ''

  iconForStep: ->
    if @isGraph
      'line-graph'
    else
      'cog'
  
  plusButton: (klass, icon, label) ->
    "<div class='step action #{klass}'><i class='entypo #{icon}'></i><span>#{label}</span></div>"
    

# Selects and edits step. Can be either step or graph,
# but we've agreed on naming convention that graph is a
# step too.
selectAndEditStep = (stepId) ->
  step = Steps.findStepOrGraph(stepId)
  Session.set('editedObject', step)
  Session.set('selectedStep', step)


Template.source_show.events
  # General

  'keydown textarea': (e) ->
    if e.keyCode == 9
      insertAtCaret(e.currentTarget, '  ')
      e.preventDefault()

  'click button.flow': (e) ->
    e.preventDefault()
    Router.go('flow.edit', @)

  'click button.dashboard': (e) ->
    e.preventDefault()
    Router.go('dashboard.show', @)

  # Steps

  # This event simply edits step that user just clicked on.
  'click div.step.collapsed': (e) ->
    return if Sources.isA(@)
    Session.set('editedObject', @)

  # This event is responsible for clicking the add step button
  # and it creates a new step at the approprite place.
  # Once the step is created, it edits it, and also selects its
  # branch by setting session variable `selectedStep`.
  'click .action.add-step': (e, template) ->
    e.preventDefault()
    source = template.data
    params =
      sourceId: source._id
      weight: Steps.nextWeight(source)
      title: 'Map'
      code: Steps.DEFAULT_CODE
      # TODO: This should be either current branch (by selectedStep) or start at the beginning
      inputStepId: Steps.lastIdForSource(source)
      y: Steps.nextY(source)
      x: Steps.lastX(source)

    Steps.insert params, (err, stepId) ->
      selectAndEditStep(stepId)

  # Graphs

  # This is similar code as similar but for adding a line
  # chart.
  'click .action.add-line-chart': (e, template) ->
    e.preventDefault()
    source = template.data
    params =
      sourceId: source._id,
      title: 'Viz',
      code: LINE_CHART_CODE,
      inputStepId: Steps.lastIdForSource(source)
      y: Steps.nextY(source)
      x: Steps.lastX(source)

    Graphs.insert params, (err, stepId) ->
      selectAndEditStep(stepId)

  'click .action.add-bar-chart': (e, template) ->
    e.preventDefault()
    source = template.data
    Graphs.insert {
      sourceId: source._id,
      title: 'Viz',
      code: BAR_CHART_CODE,
      inputStepId: Steps.lastIdForSource(source)
      y: Steps.nextY(source)
      x: Steps.lastX(source)
    }, Flash.handle

  'click div.graph.collapsed': (e) ->
    Graphs.set(@_id, {expanded: true}, Flash.handle)

  'click input.delete-graph': (e) ->
    e.preventDefault()
    Graphs.remove({_id: @_id}, Flash.handle)