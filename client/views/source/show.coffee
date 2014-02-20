manager = null

Template.source_show.created = ->
  source = @data
  manager = new SourceManager(source)

  Deps.autorun ->
    Session.set 'preview', manager.preview()


Template.source_show.helpers
  dataPreview: ->
    Session.get('preview')

  dataPreviewObject: ->
    preview = Session.get('preview')
    values = []
    for k, v of preview
      values.push({key: k, value: v})
    values

  is2D: ->
    preview = Session.get('preview')
    result = preview instanceof Array && preview.length > 0 && preview[0] instanceof Array
    console.log 'is2D', result
    result

  is1D: ->
    preview = Session.get('preview')
    result = preview instanceof Array && preview.length > 0 && !(preview[0] instanceof Array)
    console.log 'is1D', result
    result

  isObject: ->
    preview = Session.get('preview')
    result = !(preview instanceof Array) && preview instanceof Object
    console.log 'isObject', result
    result

  isNumber: ->
    preview = Session.get('preview')
    result = typeof preview == 'number'
    console.log 'isNumber', result
    result

  isArray: ->
    preview = Session.get('preview')
    if preview[0] instanceof Array
      true
    else
      false
    

  dataColumns: ->
    preview = Session.get('preview')
    return [] unless preview
    row = preview[0]    
    row.map (col, i) ->
      i + 1

  steps: ->
    Steps.forSource(@)

  graphs: ->
    Graphs.forSource(@)

Template.source_show.events
  # General

  'keydown textarea': (e) ->
    if e.keyCode == 9
      insertAtCaret(e.currentTarget, '  ')
      e.preventDefault()

  # Steps

  'click a.add-step': (e) ->
    e.preventDefault()

    params =
      sourceId: @_id
      weight: Steps.nextWeight()
      title: 'Map'
      code: Steps.DEFAULT_CODE

    Steps.insert params, (e) ->
      console.log 'Finished inserting', e

  'click div.step.collapsed': (e) ->
    Steps.set(@_id, expanded: true)

  'submit form.step': (e) ->
    e.preventDefault()
    data = $(e.currentTarget).serializeObject()
    data.expanded = false

    Steps.update {_id: @_id}, {$set: data}, (err) ->
      console.log 'err', err

  'click input.delete-step': (e) ->
    e.preventDefault()
    Steps.remove {_id: @_id}

  # Graphs

  'click a.add-graph': (e) ->
    e.preventDefault()

    params =
      sourceId: @_id
      title: 'Viz'
      code: '// viz code here'

    Graphs.insert params, (err) ->
      console.log 'failed', err if err

  'click div.graph.collapsed': (e) ->
    Graphs.set(@_id, expanded: true)