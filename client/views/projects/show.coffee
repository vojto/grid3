class ProjectShow extends Grid.Controller
  events:
    'click .add-source': 'addSource'

  helpers:
    'sources': 'sources'
    'graphs': 'graphs'
    'tables': 'tables'

  sources: ->
    Sources.find()

  addSource: ->
    Router.go 'source.new'

  graphs: ->
    Graphs.forProject(@)

  tables: ->
    Tables.forProject(@)

new ProjectShow(Template.project_show)