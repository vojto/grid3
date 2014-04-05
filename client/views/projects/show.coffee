class ProjectShow extends Grid.Controller
  events:
    'click .add-source': 'addSource'
    'click .add-table': 'addTable'
    'click .delete-table': 'deleteTable'
    'click .edit-table': 'editTable'

  helpers:
    'sources': 'sources'
    'graphs': 'graphs'
    'tables': 'tables'

  # Working with sources
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  sources: ->
    Sources.find()

  addSource: ->
    Router.go 'source.new'

  # Working with graphs
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  graphs: ->
    Graphs.forProject(@)

  # Working with tables
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  tables: ->
    Tables.forProject(@)

  addTable: ->
    Tables.createForProject(@, {
      title: 'New table'  
    }, (err, id) ->
      Flash.handle(err)
      Router.go 'table.edit', {_id: id}
    )

  deleteTable: ->
    Tables.remove(@_id)

  editTable: ->
    Router.go 'table.edit', {_id: @_id}

new ProjectShow(Template.project_show)