Template.flow_edit.events
  'click button.editor': (e, template) ->
    Router.go 'source.show', @

$flow = null

didStopDragging = (ev, ui) ->
  $el = $(ev.target)
  id = $el.attr('data-id')
  pos = $el.position()
  x = pos.left
  y = pos.top

  Steps.update({_id: id}, {$set: {x: x, y: y}})

Template.flow_edit.rendered = ->
  $flow = $(@find('#flow'))

Template.flow_edit.helpers
  steps: ->
    Steps.forSource(@)

  updateStep: (template) ->
    setTimeout ->
      $flow.find('div.step').draggable({stop: didStopDragging})
    , 0
    ''

  stepStyle: (step) ->
    console.log 'coming up with style for', @
    "left: #{@x}px; top: #{@y}px; "