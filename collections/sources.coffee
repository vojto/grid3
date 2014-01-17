@Sources = new Meteor.Collection2 "sources",
  schema:
    title:      { type: String, label: 'Title', optional: true }
    url:        { type: String, label: 'URL' }
    cachedData: { type: String, label: 'Cached data', optional: true }

@Sources.allow
  insert: (userId, doc) -> true
  update: (userId, doc) -> true
  remove: (userId, doc) -> true
