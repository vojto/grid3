Template.flow_edit.events
  'click button.editor': (e, template) ->
    Router.go 'source.show', @

Template.flow_edit.rendered = ->
  console.log 'data', @data