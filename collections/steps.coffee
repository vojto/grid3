@Steps = new Meteor.Collection2 "steps",
  schema:
    collection: { type: String, autoValue: -> 'steps' }
    projectId: { type: String, optional: true } # TODO: Get rid of this
    weight: { type: Number, label: 'Weight', optional: true } # TODO: Get rid of this
    title: { type: String, label: 'Title' }
    code: { type: String, label: 'Code' }
    expanded: { type: Boolean, label: 'expanded', optional: true }
    x: { type: Number, label: 'X', optional: true }
    y: { type: Number, label: 'Y', optional: true }
    inputSourceIds: { type: [String], optional: true }
    tableId: { type: String, optional: true }

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

  # Do this for reactivity to work
  steps = Steps.find({_id: {$in: stepIds}}).fetch()
  # Do this to keep them in order
  steps = stepIds.map (id) -> Steps.findOne(id)
  # Add the final step
  steps.push(selected)
  steps

# Finds all sources for a step
@Steps.sources = (step) ->
  return [] unless step
  Steps.findArray(step.inputSourceIds)

@Steps.DEFAULT_CODE = {
  'map': 'return data.map(function(d) {\n  return d;\n});',
  'reduce': 'return data.reduce(function(sum, d) {\n  return d;\n}, {});'
  'group': 'return data.group([0], function(sum, d) {\n\t\n});';
}
