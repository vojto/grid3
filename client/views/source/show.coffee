Template['source.show'].rendered = ->
  console.log 'rendering show'
  console.log 'data', @data
  url = @data.url

  IronRouterProgress.start()
  Meteor.call 'sources.load', url, (err, data) ->
    IronRouterProgress.done()
    console.log 'finished loading', err, data
    Session.set 'dataPreview', data.slice(0, 5)

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