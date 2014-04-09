class TableEditController extends Grid.Controller
  helpers:
    'sources': 'tableSources'
    'allSources': 'allSources'
    'steps': 'steps'
    'addStepLink': 'addStepLink'
    'stepClass': 'stepClass'

  actions:
    'click .add-source': 'addSource'
    'click .delete-source': 'deleteSource'
    'click .add-step': 'addStep'
    'click .delete-step': 'deleteStep'
    'click li.step': 'openStep'

  table: ->
    Router.getData().table

  # Working with sources
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  tableSources: ->
    table = @table()
    return [] unless table
    Tables.sources(table)

  allSources: ->
    table = @table()
    return [] unless @table()
    Sources.find().fetch().filter (availableSource) ->
      table.sourceIds.indexOf(availableSource._id) == -1

  # Adds available source to the table source
  addSource: (source) ->
    table = @template.data
    Tables.update({_id: table._id}, {$addToSet: {sourceIds: source._id}})

  deleteSource: (source) ->
    table = @template.data
    Tables.update({_id: table._id}, {$pull: {sourceIds: source._id}})


  # Working with steps
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  steps: (data) ->
    table = @table()
    return [] unless table
    Tables.steps(table)

  stepClass: (step) ->
    currentStep = Router.getData().step
    if currentStep && step._id == currentStep._id
      'active'
    else
      ''

  # Adds clicked step to the current table
  addStep: (step) ->
    table = @template.data
    params =
      title: step.label
      code: Steps.DEFAULT_CODE[step.step]

    Steps.insert params, (err, stepId) ->
      Flash.handle(err)
      return unless stepId
      Tables.addStepWithId(table, stepId)

  deleteStep: (step) ->
    table = @template.data
    Tables.update({_id: table._id}, {$pull: {stepIds: step._id}})
    Steps.remove(step._id)

  openStep: (step) ->
    table = @template.data.table
    Router.go 'step.edit', {tableId: table._id, stepId: step._id}


controller = new TableEditController()
controller.addTemplate(Template.table_edit)
controller.addTemplate(Template.table_sidebar)
