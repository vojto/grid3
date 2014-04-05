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

  steps: ->
    Tables.steps(@)

  # Adds clicked step to the current table
  addStep: (step) ->
    table = @template.data
    stepType = step.step
    params =
      title: 'Map'
      code: Steps.DEFAULT_CODE[stepType]

    Steps.insert params, (err, stepId) ->
      Flash.handle(err)
      console.log 'created step with params', params, 'and id', stepId
      return unless stepId
      Tables.addStepWithId(table, stepId)
      # Add this step to array of steps for current table



new TablesEdit(Template.table_edit)
