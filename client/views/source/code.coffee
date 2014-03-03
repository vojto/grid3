Template.source_code.helpers
  object: ->
    Session.get('editedObject')

Template.source_code.rendered = ->
  $code = @find('.code')
  return unless $code

  editor = new ReactiveAce()
  editor.theme = "tomorrow_night_blue"
  editor.syntaxMode = "javascript"

  editor.attach($code)


  editor.theme = "tomorrow_night"
  editor.syntaxMode = "javascript"
  editor.fontSize = 14