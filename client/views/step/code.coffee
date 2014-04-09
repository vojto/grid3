class StepCodeEditor extends Grid.Controller
  didRender: (template) ->
    $code = @template.find('.code')

    @editor = new ReactiveAce()

    @editor.attach($code)
    @editor.theme = "tomorrow_night"
    @editor.syntaxMode = "javascript"
    @editor.fontSize = 14

    @editor._editor.commands.addCommand
      name: 'saveCode'
      bindKey: {mac: 'Command-S', win: 'Ctrl-S'}
      exec: (editor) =>
        $(document).trigger('editorSaveShortcut')

    Deps.autorun =>
      step = @template.data
      @editor._editor.setValue(step.code, 1)

class StepCode extends Grid.Controller
  actions:
    'click .submit': 'saveEditedObject'
    'submit form': 'saveEditedObject'
    'click .delete': 'deleteEditedObject'
    'click i.back': 'goBack'

  constructor: ->
    super

  didRender: (template) ->
    shortcuts = ['ctrl+s', 'command+s', 'command+return', 'ctrl+return', 'ctrl+enter']
    Mousetrap.bind shortcuts, (e) =>
      e.preventDefault()
      @saveEditedObject()

    $(document).bind 'editorSaveShortcut', =>
      @saveEditedObject()


    

  saveEditedObject: ->
    template = @template
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

  deleteEditedObject: (step) ->
    if confirm("Are you sure you want to remove step #{step.title}?")    
      projectId = step.projectId
      Steps.remove {_id: step._id}
      Graphs.remove {_id: step._id}
      Router.go 'flow.edit', {_id: projectId} 

  goBack: (step) ->
    Router.go 'table.edit', {_id: step.tableId}

new StepCode(Template.source_code)
new StepCodeEditor(Template.source_code_editor)