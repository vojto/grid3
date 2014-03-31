# Variables
# -----------------------------------------------------------------------------

$flow = null
$arrow = null
isArrowing = false
$source = null
sourceStep = null

# View lifecycle
# -----------------------------------------------------------------------------

didRender = ->
  $flow = $(@find('#flow'))
  setupKeyboardShortcuts()

setupKeyboardShortcuts: ->
  shortcuts = ['backspace', 'del']
  Mousetrap.bind shortcuts, (e) =>
    e.preventDefault()
    deleteSelectedLine()

setupDragging = ->
  $(@find('div.step')).draggable({stop: didStopDragging})

# General helpers
# -----------------------------------------------------------------------------

mousePositionInSvg = (e) ->
  svgPosition = $('svg').offset()
  svgX = svgPosition.left
  svgY = svgPosition.top
  mouseX = e.clientX - svgX
  mouseY = e.clientY - svgY
  {x: mouseX, y: mouseY}

itemStyle = (step) ->
  "left: #{@x || 10}px; top: #{@y || 10}px; "


# Finding all arrows
# -----------------------------------------------------------------------------

styleLine = (line) ->
  selectedLineId = Session.get('selectedLineId')
  if selectedLineId && line.id == selectedLineId
    line.color = '#4aa8ff'
    line.marker = 'url(#head-selected)'
  else
    line.color = '#fff'
    line.marker = 'url(#head)'  

arrows = ->
  lines = []
  collectRegularConnection = (object) ->
    input = Steps.findOne({_id: object.inputStepId})
    return unless input

    lines.push({
      id: object._id
      x1: object.x + 10
      y1: object.y
      x2: input.x + 15
      y2: input.y + 25
    })

  collectSourceConnection = (step) ->
    for sourceId in step.inputSourceIds || []
      source = Sources.findOne(sourceId)

      lines.push({
        id: step._id
        x1: step.x + 10
        y1: step.y
        x2: source.x + 15
        y2: source.y + 25
      })


  Steps.forProject(@).forEach(collectRegularConnection)
  Steps.forProject(@).forEach(collectSourceConnection)
  Graphs.forProject(@).forEach(collectRegularConnection)

  lines.forEach(styleLine)

  lines

# Drawing arrows
# -----------------------------------------------------------------------------

startArrowing = (e, step) ->
  $(e.currentTarget).addClass('edited')
  isArrowing = true
  $source = e.currentTarget
  sourceStep = step

  $arrow = document.createElementNS('http://www.w3.org/2000/svg','line')
  $("svg").append($arrow)

  $($arrow).attr('stroke', '#4aa8ff')
    .attr('stroke-width', '2')
    .attr('marker-start', 'url(#head-selected)')

finishArrowing = ->
  $('#flow div.step').removeClass('edited')
  isArrowing = false
  sourceStep = null
  targetStep = null
  $($arrow).remove()

updateArrowing = (e) ->
  return unless isArrowing

  sourcePosition = $($source).position()
  sourceX = sourcePosition.left + 15
  sourceY = sourcePosition.top + 25
  mouse = mousePositionInSvg(e)

  $($arrow).attr({
    x1: mouse.x,
    y1: mouse.y,
    x2: sourceX,
    y2: sourceY
  })

# Dragging
# -----------------------------------------------------------------------------

didStopDragging = (ev, ui) ->
  $el = $(ev.target)
  id = $el.attr('data-id')
  pos = $el.position()
  x = pos.left
  y = pos.top

  Steps.update({_id: id}, {$set: {x: x, y: y}})
  Graphs.update({_id: id}, {$set: {x: x, y: y}})
  Sources.update({_id: id}, {$set: {x: x, y: y}})

## Creating and connecting steps
# -----------------------------------------------------------------------------

didMouseUpAtCanvas = (e, template) ->
  project = template.data
  mouse = mousePositionInSvg(e)

  if isArrowing && e.target.nodeName == 'line'
    createConnectionWithoutTarget(project, mouse)
    
  finishArrowing()

createConnectionWithoutTarget = (project, mouse) ->
  if sourceStep.collection == 'sources'
    # Create connection with a source
    Steps.insertEmptyWithInputSource(project, sourceStep, mouse)
  else
    Steps.insertEmptyWithInputStep(project, sourceStep, mouse)

didMouseUpAtStep = (e) ->
  e.preventDefault()
  createConnectionWithTarget(@)

createConnectionWithTarget = (step) ->
  return unless sourceStep

  if sourceStep.collection == 'sources'
    # Create connection with a source
    Steps.update({_id: step._id}, {$push: {inputSourceIds: sourceStep._id}})
  else
    # Create connection between steps/graphs
    Steps.updateStepOrGraph(@_id, {inputStepId: sourceStep._id})

deleteSelectedLine = ->
  selectedLineId = Session.get('selectedLineId')
  Steps.updateStepOrGraph(selectedLineId, {inputStepId: null})

# Events
# -----------------------------------------------------------------------------

Template.flow_edit.events
  'click svg': (e) ->
    if e.target.nodeName != 'line'
      Session.set('selectedLineId', null)

  'click line': (e) ->
    Session.set('selectedLineId', @id)

  'mousedown div.step': (e) ->
    return true unless e.ctrlKey
    startArrowing(e, @)

  'click div.step span': (e, template) ->
    e.preventDefault()
    Router.go 'step.edit', {branchId: @_id, _id: @_id}

  'mouseup #flow': didMouseUpAtCanvas

  'contextmenu div.step': (e) ->
    e.preventDefault()
    false

  'mousemove #flow': (e) ->
    e.preventDefault()
    updateArrowing(e)

  'mouseover div.step': (e) ->
    e.preventDefault()
    $(e.currentTarget).addClass('edited') if isArrowing

  'mouseout div.step': (e) ->
    e.preventDefault()
    if isArrowing && e.currentTarget != $source
      $(e.currentTarget).removeClass('edited') 

  'mouseup div.step': didMouseUpAtStep
    

  'dragstart div.step': (e) ->
    e.preventDefault() if e.ctrlKey

Template.flow_edit_step.rendered = setupDragging
Template.flow_edit_graph.rendered = setupDragging
Template.flow_edit_source.rendered = setupDragging

Template.flow_edit.helpers
  lines: arrows
  sources: -> Sources.forProject(@)
  steps: -> Steps.forProject(@)
  graphs: -> Graphs.forProject(@)

Template.flow_edit_step.helpers(itemStyle: itemStyle)
Template.flow_edit_graph.helpers(itemStyle: itemStyle)
Template.flow_edit_source.helpers(itemStyle: itemStyle)
Template.flow_edit.rendered = -> didRender

