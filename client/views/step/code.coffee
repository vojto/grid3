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

  helpers:
    'object': 'editedObject'

  constructor: ->
    super

  didRender: (template) ->
    shortcuts = ['ctrl+s', 'command+s', 'command+return', 'ctrl+return', 'ctrl+enter']
    Mousetrap.bind shortcuts, (e) =>
      e.preventDefault()
      @saveEditedObject()

    $(document).bind 'editorSaveShortcut', =>
      @saveEditedObject()

  editedObject: ->
    data = Router.getData()
    data.step || data.graph

  saveEditedObject: ->
    template = @template
    object = @editedObject()
    return unless object

    $form = $(template.find('form'))
    $editor = template.find('div.code')
    data = $form.serializeObject()
    data.code = ace.edit($editor).getValue()
    object.code = data.code # to update live
    object.title = data.title
    data.expanded = false

    Steps.set(object._id, data, Flash.handle)
    Graphs.set(object._id, data, Flash.handle)

    if object.collection == 'steps'
      Router.go 'step.edit', {tableId: object.tableId, stepId: object._id}
    else
      Router.go 'graph.edit', {tableId: object.tableId, graphId: object._id}

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