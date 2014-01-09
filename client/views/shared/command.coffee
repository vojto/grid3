Template.shared_command.helpers
  message: ->
    Session.get 'message'
    # "Welcome to GRID. I’ll need a data source to get started. Paste URL in the field below."

Template.shared_command.events
  'submit form': (ev) ->
    ev.preventDefault()

    $form = $(ev.currentTarget)
    command = $form.serializeObject().command
    $form.find('input').val('')

    commandPrompt.processCommand(command)

    