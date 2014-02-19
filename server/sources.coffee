d3 = Meteor.require('d3')

findArray = (obj) ->
  if obj instanceof Array && obj.length > 0
    obj
  else if obj instanceof Object
    for key, value of obj
      result = findArray(value)
      return result if result
  else
    null

Meteor.methods
  'sources.load': (url) ->
    console.log 'loading', url
    data = HTTP.get url

    # TODO: Logic for determining response format
    # For now we'll just go with JSON

    try
      # Try JSON
      parsed = JSON.parse(data.content)
    catch e
      parsed = d3.csv.parseRows(data.content)

    findArray(parsed)