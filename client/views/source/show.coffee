manager = null
    
Template.source_show.helpers
  dataColumns: ->
    preview = Session.get('preview')
    return [] unless preview
    row = preview[0]    
    row.map (col, i) ->
      i + 1

  steps: ->
    console.log 'getting steps for source', @
    Steps.forSource(@)

  graphs: ->
    Graphs.forSource(@)

  currentClass: ->
    edited = Session.get('editedObject')
    if edited && edited._id == @_id
      'edited'
    else
      ''
    

Template.source_show.events
  # General

  'keydown textarea': (e) ->
    if e.keyCode == 9
      insertAtCaret(e.currentTarget, '  ')
      e.preventDefault()

  # Steps

  'click .action.add-step': (e) ->
    e.preventDefault()

    params =
      sourceId: @_id
      weight: Steps.nextWeight(@)
      title: 'Map'
      code: Steps.DEFAULT_CODE

    Steps.insert params, Flash.handle

  'click div.step.collapsed': (e) ->
    if @title && @url # type is source
      Session.set('editedObject', null)
    else
      Session.set('editedObject', @)

  # Graphs

  'click .action.add-graph': (e) ->
    e.preventDefault()
    Graphs.insert {sourceId: @_id, title: 'Viz', code: '//\n'}, Flash.handle

  'click div.graph.collapsed': (e) ->
    Graphs.set(@_id, {expanded: true}, Flash.handle)

  'click input.delete-graph': (e) ->
    e.preventDefault()
    Graphs.remove({_id: @_id}, Flash.handle)