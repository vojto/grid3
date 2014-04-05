class TablesEdit extends Grid.Controller
  helpers:
    'sources': 'tableSources'
    'steps': 'steps'
    'allSources': 'allSources'

  table: ->
    Router.getData()

  tableSources: ->
    Tables.sources(@)

  allSources: ->
    Sources.find()

  steps: ->
    Tables.steps(@)


new TablesEdit(Template.table_edit)