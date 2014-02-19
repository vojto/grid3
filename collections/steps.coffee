@Steps = new Meteor.Collection2 "steps",
  schema:
    sourceId: { type: String }
    weight: { type: Number, label: 'Weight' }
    title: { type: String, label: 'Title', optional: true }
    code: { type: String, label: 'Code' }
    expanded: { type: Boolean, label: 'expanded', optional: true }

@Steps.allow
  insert: (userId, doc) -> true
  update: (userId, doc) -> true
  remove: (userId, doc) -> true