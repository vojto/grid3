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
  lines: ->
    lines = []
    collect = (object) ->
      input = Steps.findOne({_id: object.inputStepId})
      return unless input
      lines.push({
        x1: object.x + 10
        y1: object.y
        x2: input.x + 15
        y2: input.y + 25
      })

    Steps.forSource(@).forEach(collect)
    Graphs.forSource(@).forEach(collect)

    console.log 'lines', lines
    lines

  steps: ->
    Steps.forSource(@)

  graphs: ->
    Graphs.forSource(@)

  updateStep: (template) ->
    setTimeout ->
      $flow.find('div.step').draggable({stop: didStopDragging})
    , 0
    ''

  itemStyle: (step) ->
    "left: #{@x || 10}px; top: #{@y || 10}px; "

  # x1: ->
  #   @x + 10

  # y1: ->
  #   @y

  # x2: ->
  #   input = Steps.findOne({_id: @inputStepId})
  #   input.x + 15 if input

  # y2: ->
  #   input = Steps.findOne({_id: @inputStepId})
  #   input.y + 25 if input