@Steps = new Meteor.Collection2 "steps",
  schema:
    collection: { type: String, autoValue: -> 'steps' }
    projectId: { type: String }
    weight: { type: Number, label: 'Weight' }
    title: { type: String, label: 'Title', optional: true }
    code: { type: String, label: 'Code' }
    expanded: { type: Boolean, label: 'expanded', optional: true }
    x: { type: Number, label: 'X', optional: true }
    y: { type: Number, label: 'Y', optional: true }
    inputStepId: { type: String, optional: true }
    inputSourceIds: { type: [String], optional: true }

@Steps.allow
  insert: (userId, doc) -> true
  update: (userId, doc) -> true
  remove: (userId, doc) -> true

@Steps.lastForProject = (project) ->
  Steps.findOne({projectId: project._id}, {sort: {weight: -1}})

@Steps.forProject = (project) ->
  Steps.find({projectId: project._id}, {sort: {weight: 1}})

@Steps.nextWeight = (project) ->
  step = Steps.lastForProject(project)
  if step
    return step.weight + 1
  else
    return 0

@Steps.nextY = (project) ->
  step = Steps.lastForProject(project)
  if step
    return step.y + 40
  else
    return 40

@Steps.lastX = (project) ->
  step = Steps.lastForProject(project)
  if step
    return step.x
  else
    return 40

@Steps.lastIdForProject = (project) ->
  step = @lastForProject(project)
  if step
    step._id
  else
    null

@Steps.insertEmptyWithInputStep = (project, inputStep, extraParams={}) ->
  params =
    projectId: project._id
    weight: Steps.nextWeight(project)
    title: 'Map'
    code: Steps.DEFAULT_CODE
    inputStepId: inputStep._id
    y: Steps.nextY(project)
    x: Steps.lastX(project)
  _.extend(params, extraParams)

  Steps.insert params, Flash.handle

@Steps.insertEmptyWithInputSource = (project, source, extraParams={}) ->
  params =
    projectId: project._id
    weight: Steps.nextWeight(project)
    title: 'Map'
    code: Steps.DEFAULT_CODE
    inputStepId: null
    inputSourceIds: [source._id]
    y: Steps.nextY(project)
    x: Steps.lastX(project)
  _.extend(params, extraParams)

  Steps.insert params, Flash.handle


@Steps.updateStepOrGraph = (id, attrs) ->
  sel = {_id: id}
  set = {$set: attrs}
  Steps.update(sel, set, Flash.handle)
  Graphs.update(sel, set, Flash.handle)

@Steps.findStepOrGraphBy = (query) ->
  item = Steps.findOne(query)
  item or= Graphs.findOne(query)
  item

@Steps.findStepOrGraph = (id) ->
  Steps.findStepOrGraphBy({_id: id})

@Steps.stepsUpUntil = (selected) ->
  return [] unless selected
  selectedId = selected._id
  stepIds = []
  previousId = selectedId
  previous = selected
  while previousId
    previous or= Steps.findOne({_id: previousId})
    previous = Steps.findOne({_id: previous.inputStepId}) if previous
    if previous
      previousId = previous._id
      stepIds.unshift(previousId)
    else
      previousId = null
  
  steps = Steps.find({_id: {$in: stepIds}}).fetch()
  steps.push(selected)
  steps

@Steps.DEFAULT_CODE = 'return data.map(function(d) {\n  return d;\n});'