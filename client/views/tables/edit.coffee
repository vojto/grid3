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

  tableSources: (table) ->
    console.log 'looking for table sources'
    return [] unless table
    Tables.sources(table)

  allSources: ->
    table = @table()
    console.log 'finding sources for table', table
    Sources.find().fetch().filter (availableSource) ->
      table.sourceIds.indexOf(availableSource._id) != -1

  # Adds available source to the table source
  addSource: (source) ->
    return unless @template
    return
    table = @template.data
    Tables.update({_id: table._id}, {$push: {sourceIds: source._id}})


  # Working with steps
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  steps: ->
    Tables.steps(@)


new TablesEdit(Template.table_edit)