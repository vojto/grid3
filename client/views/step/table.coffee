Template.source_table.helpers
  wantsTable: ->
    editedObject = Session.get('editedObject')

    if !editedObject
      true
    else if editedObject.isGraph
      false
    else
      true

  dataPreview: ->
    preview = Session.get('preview')
    preview

  dataPreviewObject: ->
    preview = Session.get('preview')
    values = []
    for k, v of preview
      values.push({key: k, value: v})
    values

  is2D: ->
    preview = Session.get('preview')
    result = preview instanceof Array && preview.length > 0 && preview[0] instanceof Array
    result

  is1D: ->
    preview = Session.get('preview')
    result = preview instanceof Array && preview.length > 0 && !(preview[0] instanceof Array)
    result

  isObject: ->
    preview = Session.get('preview')
    result = !(preview instanceof Array) && preview instanceof Object
    result

  isNumber: ->
    preview = Session.get('preview')
    result = typeof preview == 'number'
    result

  isArray: ->
    preview = Session.get('preview')
    if preview[0] instanceof Array
      true
    else
      false