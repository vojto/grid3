Template['source.show'].rendered = ->
  console.log 'rendering show'
  console.log 'data', @data

  source = @data
  data = null

  manager = new SourceManager(source)
  manager.loadData ->
    Session.set 'dataPreview', manager.preview()

Template['source.show'].helpers
  dataPreview: ->
    Session.get('dataPreview')

  dataColumns: ->
    preview = Session.get('dataPreview')
    return [] unless preview
    row = preview[0]    
    console.log row
    row.map (col, i) ->
      i + 1