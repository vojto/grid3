Template['source.show'].rendered = ->
  console.log 'rendering show'
  console.log 'data', @data
  url = @data.url

  Meteor.call 'sources.load', url, (err, data) ->
    console.log 'finished loading', err, data