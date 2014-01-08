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

    findArray(JSON.parse(data.content))