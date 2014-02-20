Meteor.Collection2.prototype.set = (id, updates, callback) ->
  @update({_id: id}, {$set: updates}, callback)