@Graphs = new Meteor.Collection2 'graphs',
  schema:
    inputSourceId: { type: String }
    title: { type: String, label: 'Title', optional: true }
    code: { type: String, label: 'Code' }
    expanded: { type: Boolean, label: 'expanded', optional: true }
    isGraph: { type: Boolean, label: 'graph', autoValue: -> true }

@Graphs.allow
  insert: (userId, doc) -> true
  update: (userId, doc) -> true
  remove: (userId, doc) -> true

@Graphs.forSource = (source) ->
  Graphs.find({sourceId: source._id})