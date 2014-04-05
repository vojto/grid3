class TablesEdit extends Grid.Controller
  helpers:
    'sources': 'tableSources'
    'allSources': 'allSources'
    'steps': 'steps'
    'addStepLink': 'addStepLink'

  actions:
    'click .add-source': 'addSource'
    'click .delete-source': 'deleteSource'
    'click .add-step': 'addStep'
    'click .delete-step': 'deleteStep'

  table: ->
    Router.getData()

  # Working with sources
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  tableSources: (table) ->
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

  steps: (table) ->
    Tables.steps(table)

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



new TablesEdit(Template.table_edit)
