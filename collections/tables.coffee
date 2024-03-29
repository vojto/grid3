@Tables = new Meteor.Collection2 'tables',
  schema:
    projectId: { type: String }
    title: { type: String, label: 'Title', optional: true }
    sourceIds: { type: [String], label: 'Sources' }
    stepIds: { type: [String], label: 'Steps' }
    graphIds: { type: [String], label: 'Graphs' }

@Tables.allow
  insert: (userId, doc) -> true
  update: (userId, doc) -> true
  remove: (userId, doc) -> true

@Tables.forProject = (project) ->
  Tables.find({projectId: project._id})

@Tables.createForProject = (project, attrs, cb) ->
  attrs.projectId = project._id
  attrs.sourceIds = []
  attrs.stepIds = []
  Tables.insert(attrs, cb)

@Tables.firstStep = (table) ->
  return null unless table.steps
  return null unless table.steps.length == 0
  id = table.steps[0]
  Steps.find(id)

@Tables.steps = (table) ->
  Steps.findArray(table.stepIds)

@Tables.sources = (table) ->
  Sources.findArray(table.sourceIds)

@Tables.addStepWithId = (table, stepId) ->
  Tables.update(table._id, {$addToSet: {stepIds: stepId}})
  Steps.update(stepId, {$set: {tableId: table._id}})

@Tables.graphs = (table) ->
  Graphs.findArray(table.graphIds)

@Tables.addGraphWithId = (table, graphId) ->
  Tables.update(table._id, {$addToSet: {graphIds: graphId}})
  Graphs.update(graphId, {$set: {tableId: table._id}})