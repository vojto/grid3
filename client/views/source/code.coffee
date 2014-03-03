Template.source_code.events
  'click .submit': (e, template) ->
    e.preventDefault()
    $form = $(template.find('form'))
    $editor = template.find('div.code')
    data = $form.serializeObject()
    data.code = ace.edit($editor).getValue()
    console.log 'data', data
    data.expanded = false

    # This is a terrible hack, but one of this will succeed, and the
    # other one will fail.
    Steps.set(@_id, data, Flash.handle)
    Graphs.set(@_id, data, Flash.handle)

  'click .delete': (e) ->
    e.preventDefault()
    if confirm("Are you sure you want to remove step #{@title}?")    
      Steps.remove {_id: @_id}