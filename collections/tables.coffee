@Tables = new Meteor.Collection2 'tables',
  schema:
    projectId: { type: String }
    title: { type: String, label: 'Title', optional: true }
    stepsIds: { type: [String], label: 'Steps' }

@Tables.allow
  insert: (userId, doc) -> true
  update: (userId, doc) -> true
  remove: (userId, doc) -> true

@Tables.forProject = (project) ->
  Tables.find({projectId: project._id})

@Tables.createForProject = (project, attrs, cb) ->
  attrs.projectId = project._id
  Tables.insert(attrs, cb)

@Tables.firstStep = (table) ->
  return null unless table.steps
  return null unless table.steps.length == 0
  id = table.steps[0]
  Steps.find(id)

@Tables.steps = (table) ->
  Steps.findArray(table.stepIds)