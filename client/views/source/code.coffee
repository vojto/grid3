saveEditedObject = (template) ->
  object = Session.get('editedObject')
  return unless object

  $form = $(template.find('form'))
  $editor = template.find('div.code')
  data = $form.serializeObject()
  data.code = ace.edit($editor).getValue()
  data.expanded = false

  Steps.set(object._id, data, Flash.handle)
  Graphs.set(object._id, data, Flash.handle)

  # Animate the button
  $button = $(template.find('.primary'))
  $button.removeClass('pulseback').addClass('pulse')
  setTimeout ->
    $button.addClass('pulseback').removeClass('pulse')
  , 200

Template.source_code.rendered = ->
  shortcuts = ['ctrl+s', 'command+s']
  Mousetrap.bind shortcuts, (e) =>
    e.preventDefault()
    saveEditedObject(@)

Template.source_code.events
  'click .submit': (e, template) ->
    e.preventDefault()
    saveEditedObject(template)
    

  'click .delete': (e) ->
    e.preventDefault()
    if confirm("Are you sure you want to remove step #{@title}?")    
      Steps.remove {_id: @_id}
      Graphs.remove {_id: @_id}
      Session.set('editedObject', null)