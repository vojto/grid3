class TablesEdit extends Grid.Controller
  helpers:
    'sources': 'sources'
    'steps': 'steps'

  table: ->
    Router.getData()

  sources: =>
    table = @table()
    return [] unless table
    step = Tables.firstStep(table)
    sources = Steps.sources(step)

    sources

  steps: ->
    Tables.steps(@)


new TablesEdit(Template.table_edit)