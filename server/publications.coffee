Meteor.publish 'sources', -> Sources.find()
Meteor.publish 'steps', -> Steps.find()
Meteor.publish 'graphs', -> Graphs.find()
Meteor.publish 'source', (id) ->
  Sources.find({_id: id})