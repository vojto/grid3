class TablesEdit extends Grid.Controller
  helpers:
    'sources': 'sources'

  table: ->
    Router.getData()

  sources: =>
    table = @table()
    return [] unless table
    step = Tables.firstStep(table)
    sources = Steps.sources(step)

    sources


new TablesEdit(Template.table_edit)