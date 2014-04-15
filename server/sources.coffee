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
  'sources.load': (id) ->
    source = Sources.findOne(id)
    console.log 'Loading source', id

    return unless source

    response = HTTP.get(source.url)
    length = response.content.length

    try
      # Try JSON
      parsed = JSON.parse(response.content)
    catch e
      parsed = d3.csv.parseRows(response.content)

    data = findArray(parsed)

    isTooLarge = length > 4000000
    console.log 'is too large?', isTooLarge

    Sources.update(source._id, {
        $set: {
          cachedData: JSON.stringify(data),
          cachedAt: new Date(),
          isTooLarge: isTooLarge
        }
      }
    )

    return data

  'sources.data': (tableId, finalStepId) ->
    manager = new Grid.SourceManager()

    step = Steps.findOne(finalStepId)
    result =  manager.data(step)

    console.log 'processed data on the server'

    return result