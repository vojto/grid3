Template['source.show'].rendered = ->
  console.log 'rendering show'
  console.log 'data', @data

  source = @data
  data = null


  if !source.cachedData
    url = source.url
    IronRouterProgress.start()
    Meteor.call 'sources.load', url, (err, res) ->
      IronRouterProgress.done()
      data = res
      update = {$set: {cachedData: JSON.stringify(data)}}
      console.log update
      Sources.update source._id, update, (err, res) ->
        console.log err, res
      Session.set 'dataPreview', data.slice(0, 5)
  else
    data = JSON.parse(source.cachedData)
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