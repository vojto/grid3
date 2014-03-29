@Projects = new Meteor.Collection2 "projects",
  schema:
    title:        { type: String, label: 'Title' }
    description:  { type: String, label: 'Description', optional: true }

@Projects.allow
  insert: (userId, doc) -> true
  update: (userId, doc) -> true
  remove: (userId, doc) -> true
