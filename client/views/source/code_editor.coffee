Template.source_code.helpers
  object: ->
    Session.get('editedObject')

Template.source_code_editor.rendered = ->
  $code = @find('.code')
  return unless $code

  if @editor
    # Editor already exists
  else
    @editor = new ReactiveAce()


  @editor.attach($code)
  @editor.theme = "tomorrow_night"
  @editor.syntaxMode = "javascript"
  @editor.fontSize = 14