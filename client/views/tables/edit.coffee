class TableEditController extends Grid.Controller
  helpers:
    'sources': 'tableSources'
    'allSources': 'allSources'
    'steps': 'steps'
    'addStepLink': 'addStepLink'
    'currentClass': 'currentClass'
    'graphs': 'graphs'

  actions:
    'click .add-source': 'addSource'
    'click .delete-source': 'deleteSource'
    'click .add-step': 'addStep'
    'click .delete-step': 'deleteStep'
    'click li.step': 'openStep'
    'click .add-vis': 'addGraph'
    'click .delete-graph': 'deleteGraph'
    'click li.graph': 'openGraph'

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
    table = @table()
    Tables.update({_id: table._id}, {$addToSet: {sourceIds: source._id}})

  deleteSource: (source) ->
    table = @table()
    Tables.update({_id: table._id}, {$pull: {sourceIds: source._id}})


  # Working with steps
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  steps: (data) ->
    table = @table()
    return [] unless table
    Tables.steps(table)

  # Adds clicked step to the current table
  addStep: (step) ->
    table = @table()
    params =
      title: step.label
      code: Steps.DEFAULT_CODE[step.step]

    Steps.insert params, (err, stepId) ->
      Flash.handle(err)
      return unless stepId
      Tables.addStepWithId(table, stepId)

  deleteStep: (step) ->
    table = @table()
    Tables.update({_id: table._id}, {$pull: {stepIds: step._id}})
    Steps.remove(step._id)

  openStep: (step) ->
    table = @table()
    Router.go 'step.edit', {tableId: table._id, stepId: step._id}

  # Working with visualization
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  graphs: ->
    table = @table()
    return [] unless table
    Tables.graphs(table)

  addGraph: ->
    table = @table()
    params =
      title: 'Visualization',
      code: Graphs.LINE_CHART_CODE,
      projectId: table.projectId

    Graphs.insert params, (err, graphId) ->
      Flash.handle(err)
      return unless graphId
      Tables.addGraphWithId(table, graphId)

  deleteGraph: (graph) ->
    table = @table()
    Tables.update({_id: table._id}, {$pull: {graphIds: graph._id}})
    Graphs.remove(graph._id)

  openGraph: (graph) ->
    Router.go 'graph.edit', {tableId: graph.tableId, graphId: graph._id}

  # Support
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  currentClass: (item) ->
    {step, graph} = Router.getData()
    if step && step._id == item._id
      'active'
    else if graph && graph._id == item._id
      'active'
    else
      ''


controller = new TableEditController()
controller.addTemplate(Template.table_edit)
controller.addTemplate(Template.table_sidebar)
