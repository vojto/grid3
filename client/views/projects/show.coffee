class ProjectShow extends Grid.Controller
  events:
    'click .add-source': 'addSource'
    'click .add-table': 'addTable'
    'click .delete-table': 'deleteTable'

  helpers:
    'sources': 'sources'
    'graphs': 'graphs'
    'tables': 'tables'

  # Working with sources

  sources: ->
    Sources.find()

  addSource: ->
    Router.go 'source.new'

  # Working with graphs

  graphs: ->
    Graphs.forProject(@)

  # Working with tables

  tables: ->
    Tables.forProject(@)

  addTable: ->
    Tables.createForProject(@, {
      title: 'New table'  
    })

  deleteTable: ->
    Tables.remove(@_id)

new ProjectShow(Template.project_show)