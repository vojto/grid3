manager = null

Template.source_show.created = ->
  source = @data
  manager = new SourceManager(source)


Template.source_show.helpers
  dataPreview: ->
    manager.preview()

  isArray: ->
    preview = manager.preview()
    if preview[0] instanceof Array
      true
    else
      false
    

  dataColumns: ->
    preview = manager.preview()
    return [] unless preview
    row = preview[0]    
    row.map (col, i) ->
      i + 1

  steps: ->
    Steps.forSource(@)

Template.source_show.events
  'click a.add-map': (e) ->
    e.preventDefault()

    step = Steps.lastForSource(@)
    if step
      weight = step.weight + 1
    else
      weight = 0

    params =
      sourceId: @_id
      weight: weight
      title: 'Map'
      code: 'data.map(function(d) {\n  return d;\n});'

    Steps.insert params, (e) ->
      console.log 'Finished inserting', e

  'click div.step.collapsed': (e) ->
    Steps.update {_id: @_id}, {$set: {expanded: true}}, (err) ->
      console.log 'Failed', err if err

  'keydown textarea': (e) ->
    if e.keyCode == 9
      insertAtCaret(e.currentTarget, '  ')
      e.preventDefault()

  'submit form': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).serializeObject()
    data.expanded = false

    Steps.update {_id: @_id}, {$set: data}, (err) ->
      console.log 'err', err

  'click input.delete': (e) ->
    e.preventDefault()
    Steps.remove {_id: @_id}