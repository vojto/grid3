# Events
# -----------------------------------------------------------------------------

Template.flow_edit.events
  'click button.editor': (e, template) ->
    Router.go 'source.show', @

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
    Router.go 'source.show', template.data
    Session.set('editedObject', @)
    Session.set('selectedStep', @)

  'mouseup #flow': (e, template) ->
    # Wants to create a new step
    if isArrowing && e.target.nodeName == 'line'
      project = template.data
      mouse = mousePositionInSvg(e)
      Steps.insertEmptyWithInputStep(project, sourceStep, {
        x: mouse.x
        y: mouse.y
      })

    finishArrowing()

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

  'mouseup div.step': (e) ->
    e.preventDefault()

    if sourceStep
      Steps.updateStepOrGraph(@_id, {inputStepId: sourceStep._id})
    

  'dragstart div.step': (e) ->
    e.preventDefault() if e.ctrlKey

Template.flow_edit_step.rendered = ->
  $(@find('div.step')).draggable({stop: didStopDragging})

Template.flow_edit_graph.rendered = ->
  $(@find('div.step')).draggable({stop: didStopDragging})

# Helpers
# -----------------------------------------------------------------------------

Template.flow_edit.helpers
  lines: ->
    lines = []
    collect = (object) ->
      input = Steps.findOne({_id: object.inputStepId})
      return unless input

      selectedLineId = Session.get('selectedLineId')
      if selectedLineId && object._id == selectedLineId
        color = '#4aa8ff'
        marker = 'url(#head-selected)'
      else
        color = '#fff'
        marker = 'url(#head)'
      
      lines.push({
        id: object._id
        x1: object.x + 10
        y1: object.y
        x2: input.x + 15
        y2: input.y + 25
        color: color
        marker: marker
      })

    Steps.forProject(@).forEach(collect)
    Graphs.forProject(@).forEach(collect)

    lines

  steps: ->
    Steps.forProject(@)

  graphs: ->
    Graphs.forProject(@)

itemStyle = (step) -> "left: #{@x || 10}px; top: #{@y || 10}px; "

Template.flow_edit_step.helpers
  itemStyle: itemStyle

Template.flow_edit_graph.helpers
  itemStyle: itemStyle

# Actions
# -----------------------------------------------------------------------------

$flow = null
$arrow = null
isArrowing = false
$source = null
sourceStep = null

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

mousePositionInSvg = (e) ->
  svgPosition = $('svg').offset()
  svgX = svgPosition.left
  svgY = svgPosition.top
  mouseX = e.clientX - svgX
  mouseY = e.clientY - svgY
  {x: mouseX, y: mouseY}

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

didStopDragging = (ev, ui) ->
  $el = $(ev.target)
  id = $el.attr('data-id')
  pos = $el.position()
  x = pos.left
  y = pos.top

  Steps.update({_id: id}, {$set: {x: x, y: y}})
  Graphs.update({_id: id}, {$set: {x: x, y: y}})

deleteSelectedLine = ->
  selectedLineId = Session.get('selectedLineId')
  Steps.updateStepOrGraph(selectedLineId, {inputStepId: null})

Template.flow_edit.rendered = ->
  $flow = $(@find('#flow'))

  shortcuts = ['backspace', 'del']
  Mousetrap.bind shortcuts, (e) =>
    e.preventDefault()
    deleteSelectedLine()

