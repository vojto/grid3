Meteor.publish 'table_columns', -> TableColumns.find()
Meteor.publish 'tables', -> Tables.find()
Meteor.publish 'steps', -> Steps.find()
Meteor.publish 'graphs', -> Graphs.find()
Meteor.publish 'tables', -> Tables.find()
Meteor.publish 'projects', -> Projects.find()
Meteor.publish 'source', (id) ->
  Sources.find({_id: id})
Meteor.publish 'project', (id) ->
  Projects.find({_id: id})