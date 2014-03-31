# Variables
# -----------------------------------------------------------------------------
manager = null

# Lifecycle
# -----------------------------------------------------------------------------

didRender = ->
  Deps.autorun(updatePreview)

updatePreview = ->
  step = Router.getData().step
  return unless step
  manager = new Grid.SourceManager()
  preview = manager.preview(step)
  Session.set('preview', preview)

openFlow = (e) ->
  e.preventDefault()
  console.log 'step', @step.projectId
  Router.go('flow.edit', {_id: @step.projectId})

# Sidebar
# -----------------------------------------------------------------------------

sidebarSteps = ->
  # This is based on the editedObject now.
  return [] unless @step

  steps = Steps.stepsUpUntil(@step)

  # Find all following steps
  next = @step
  while next = Steps.findStepOrGraphBy({inputStepId: next._id})
    steps.push(next)

  # Return result
  steps

currentClass = ->
  edited = Router.getData().step
  if edited && edited._id == @_id
    'edited'
  else
    ''

Template.step_edit.helpers
  dataColumns: ->
    preview = Session.get('preview')
    return [] unless preview
    row = preview[0]    
    row.map (col, i) ->
      i + 1

  steps: sidebarSteps
    
  currentClass: currentClass

  iconForStep: ->
    if @isGraph
      'line-graph'
    else
      'cog'
  
  plusButton: (klass, icon, label) ->
    "<div class='step action #{klass}'><i class='entypo #{icon}'></i><span>#{label}</span></div>"
    

# Selects and edits step. Can be either step or graph,
# but we've agreed on naming convention that graph is a
# step too.
selectAndEditStep = (stepId) ->
  Router.go('step.edit', {branchId: stepId, _id: stepId})

Template.step_edit.events
  # General

  'keydown textarea': (e) ->
    if e.keyCode == 9
      insertAtCaret(e.currentTarget, '  ')
      e.preventDefault()

  'click button.flow': openFlow

  'click button.dashboard': (e) ->
    e.preventDefault()
    Router.go('dashboard.show', {_id: @step.projectId})

  # Steps

  # This event simply edits step that user just clicked on.
  'click div.step.collapsed': (e) ->
    return if Sources.isA(@)
    Router.go('step.edit', {branchId: @_id, _id: @_id})

  # This event is responsible for clicking the add step button
  # and it creates a new step at the approprite place.
  # Once the step is created, it edits it, and also selects its
  # branch by setting session variable `selectedStep`.
  'click .action.add-step': (e, template) ->
    e.preventDefault()
    step = template.data.step
    project = Projects.findOne({_id: step.projectId})
    params =
      projectId: project._id
      weight: Steps.nextWeight(project)
      title: 'Map'
      code: Steps.DEFAULT_CODE
      # TODO: This should be either current branch (by selectedStep) or start at the beginning
      inputStepId: Steps.lastIdForProject(project)
      y: Steps.nextY(project)
      x: Steps.lastX(project)

    Steps.insert params, (err, stepId) ->
      selectAndEditStep(stepId)

  # Graphs

  # This is similar code as similar but for adding a line
  # chart.
  'click .action.add-line-chart': (e, template) ->
    e.preventDefault()
    step = template.data.step
    project = Projects.findOne(step.projectId)
    params =
      projectId: project._id
      title: 'Viz',
      code: Graphs.LINE_CHART_CODE,
      inputStepId: Steps.lastIdForProject(project)
      y: Steps.nextY(project)
      x: Steps.lastX(project)

    Graphs.insert params, (err, stepId) ->
      selectAndEditStep(stepId)

  'click .action.add-bar-chart': (e, template) ->
    e.preventDefault()
    step = template.data.step
    project = Projects.findOne(step.projectId)
    Graphs.insert {
      projectId: project._id,
      title: 'Viz',
      code: Graphs.BAR_CHART_CODE,
      inputStepId: Steps.lastIdForProject(project)
      y: Steps.nextY(project)
      x: Steps.lastX(project)
    }, Flash.handle

  'click div.graph.collapsed': (e) ->
    Graphs.set(@_id, {expanded: true}, Flash.handle)

  'click input.delete-graph': (e) ->
    e.preventDefault()
    Graphs.remove({_id: @_id}, Flash.handle)

# Template
# -----------------------------------------------------------------------------
Template.step_edit.rendered = didRender