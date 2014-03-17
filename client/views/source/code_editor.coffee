Template.source_code.helpers
  object: ->
    Session.get('editedObject')

Template.source_code_editor.rendered = ->
  Deps.autorun =>
    object = Session.get('editedObject')
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

    @editor._editor.setValue(object.code, 1)