codeTemplate = null

# Lifecycle
# -----------------------------------------------------------------------------

didRenderCode = ->
  codeTemplate = @
  shortcuts = ['ctrl+s', 'command+s', 'command+return', 'ctrl+return', 'ctrl+enter']
  Mousetrap.bind shortcuts, (e) =>
    e.preventDefault()
    saveEditedObject()

didRenderEditor = ->
  Deps.autorun =>
    object = Router.getData().step
    return unless object
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

    @editor._editor.commands.addCommand
      name: 'saveCode'
      bindKey: {mac: 'Command-S', win: 'Ctrl-S'}
      exec: (editor) ->
        saveEditedObject()

# Saving
# -----------------------------------------------------------------------------

saveEditedObject = ->
  template = codeTemplate
  step = Router.getData().step
  return unless step

  $form = $(template.find('form'))
  $editor = template.find('div.code')
  data = $form.serializeObject()
  data.code = ace.edit($editor).getValue()
  step.code = data.code # to update live
  step.title = data.title
  data.expanded = false

  Steps.set(step._id, data, Flash.handle)
  Graphs.set(step._id, data, Flash.handle)

  # Doing something to force re-rendering (hack)
  # Router.go 'step.edit', {tableId: null, stepId: null}
  Router.go 'step.edit', {tableId: step.tableId, stepId: step._id}

  # Animate the button
  $button = $(template.find('.primary'))
  $button.removeClass('pulseback').addClass('pulse')
  setTimeout ->
    $button.addClass('pulseback').removeClass('pulse')
  , 200

Template.source_code.events
  'click .submit': (e, template) ->
    e.preventDefault()
    saveEditedObject(template)
  
  'submit form': (e, template) ->
    e.preventDefault()
    saveEditedObject(template)

  'click .delete': (e) ->
    e.preventDefault()
    if confirm("Are you sure you want to remove step #{@title}?")    
      projectId = @projectId
      Steps.remove {_id: @_id}
      Graphs.remove {_id: @_id}
      Router.go 'flow.edit', {_id: projectId} 
  

Template.source_code.rendered = didRenderCode
Template.source_code_editor.rendered = didRenderEditor