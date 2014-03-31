@Sources = new Meteor.Collection2 "sources",
  schema:
    collection: { type: String, autoValue: -> 'sources' }
    title:      { type: String, label: 'Title', optional: true }
    url:        { type: String, label: 'URL' }
    cachedData: { type: String, label: 'Cached data', optional: true }
    x: { type: Number, label: 'X', optional: true }
    y: { type: Number, label: 'Y', optional: true }

@Sources.allow
  insert: (userId, doc) -> true
  update: (userId, doc) -> true
  remove: (userId, doc) -> true

@Sources.isA = (obj) ->
  return obj.cachedData

@Sources.forProject = (project) ->
  # For now let's now worry about the project
  # but instead return ALL of the sources
  Sources.find()