class StepCode extends Grid.Controller
  actions:
    'click .submit': 'saveEditedObject'
    'submit form': 'saveEditedObject'
    'click .delete': 'deleteEditedObject'
    'click i.back': 'goBack'

  constructor: ->
    super

  didRender: (template) ->
    console.log 'just rendered', template

    setTimeout =>
      @setupEditor()
    , 10

  setupEditor: ->
    shortcuts = ['ctrl+s', 'command+s', 'command+return', 'ctrl+return', 'ctrl+enter']
    Mousetrap.bind shortcuts, (e) =>
      e.preventDefault()
      @saveEditedObject()  


    console.log 'template', @template

    object = Router.getData().step
    $code = @template.find('.code')

    console.log 'template', @template
    console.log 'object', object
    console.log '$code', $code

    # if @editor
      # Editor already exists
    # else
    @editor = new ReactiveAce()
    console.log 'creating editor in ', $code

    @editor.attach($code)
    @editor.theme = "tomorrow_night"
    @editor.syntaxMode = "javascript"
    @editor.fontSize = 14

    @editor._editor.setValue(object.code, 1)

    @editor._editor.commands.addCommand
      name: 'saveCode'
      bindKey: {mac: 'Command-S', win: 'Ctrl-S'}
      exec: (editor) =>
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

controller = new StepCode()
controller.addTemplate(Template.source_code_editor)
controller.addTemplate(Template.source_code)