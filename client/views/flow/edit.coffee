Template.flow_edit.events
  'click button.editor': (e, template) ->
    Router.go 'source.show', @

$flow = null

Template.flow_edit.rendered = ->
  $flow = $(@find('#flow'))

Template.flow_edit.helpers
  steps: ->
    Steps.forSource(@)

  updateStep: (template) ->
    setTimeout ->
      console.log 'updating steps', $flow.find('div.step').length
      $flow.find('div.step').draggable()
    , 0
    ''