class TablesEdit extends Grid.Controller
  helpers:
    'sources': 'tableSources'
    'allSources': 'allSources'
    'steps': 'steps'

  actions:
    'click .add-source': 'addSource'

  table: ->
    Router.getData()

  # Working with sources
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  tableSources: ->
    sources = Tables.sources(@)
    console.log 'here are them sources', sources
    sources

  allSources: ->
    Sources.find()

  # Adds available source to the table source
  addSource: (source) ->
    table = @template.data
    Tables.update({_id: table._id}, {$push: {sourceIds: source._id}})


  # Working with steps
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  steps: ->
    Tables.steps(@)


new TablesEdit(Template.table_edit)