@Tables = new Meteor.Collection2 'tables',
  schema:
    projectId: { type: String }
    title: { type: String, label: 'Title', optional: true }
    inputStepId: { type: String, optional: true }

@Tables.allow
  insert: (userId, doc) -> true
  update: (userId, doc) -> true
  remove: (userId, doc) -> true

@Tables.forProject = (project) ->
  Tables.find({projectId: project._id})

@Tables.createForProject = (project, attrs, cb) ->
  attrs.projectId = project._id
  Tables.insert(attrs, cb)