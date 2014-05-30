@Grid or= {}

_instance = null

class Grid.DataManager
  @instance: ->
    _instance = new @() unless _instance
    _instance

  constructor: ->
    @_datas = {}
    @_managedTables = {}
    # This is used to reactively respond to methods requesting things about
    # tables that might change as we work with their data.
    @_managedTablesDeps = {}

    if Meteor.isClient
      Meteor.startup =>
        console.log 'startup'
        Tables.find().observeChanges
          # Here also we should only observe for changes in source and reload it.
          # This logic should also be moved to something called "Loader."
          changed: (id, fields) =>
            if fields['url']
              @reloadTable(Tables.findOne(id))

  dataForTable: (table) ->
    key = table._id
    if !@_managedTables[key]
      # We're not managing this table yet, add it to managedTables and load it
      # from the source.
      @addManagedTable(table)
      @reloadTable(table)
      return new Grid.Data()
    # @_managedTablesDeps[table._id].depend()
    if !@_datas[key]
      # The table isn't cached at the moment -- it either hasn't arrived from the
      # source yet, or there was an error. Either way, return an empty table.
      return new Grid.Data()
    @_datas[key]

  addManagedTable: (table) ->
    @_managedTables[table._id] = table
    dep = new Deps.Dependency()
    @_managedTablesDeps[table._id] = dep
    # dep.depend()

  updateManagedTableDep: (table) ->
    console.log 'updating dep', @_managedTablesDeps
    # @_managedTablesDeps[table._id].changed()

  reloadTable: (table) ->
    # Workaround for meteor not calling remote method from inside
    # this callback.
    setTimeout =>
      if not table.url or table.url == ''
        # This is the initial state after creating a table.
        return
      

      Tables.set(table._id, {isLoading: true})
      # This should now look what type of table we're dealing with, and act
      # accordingly. For now we'll just assume it's a source and load it.
      Meteor.call 'sources.load', table._id, (err, data) =>
        Tables.set(table._id, {isLoading: false}) # this probably updates the table in the UI
        return if Flash.handle(err)
        delete @_datas[table._id]
        @_datas[table._id] = new Grid.Data(data)
        @updateManagedTableDep(table)
    , 0


class Grid.Data
  constructor: (data) ->
    # TODO: Instead of expecting prepared cached data,
    # figure out the whole trip to server and caching
    # and stuff like that.

    if !data
      @_isEmpty = true
      return

    @_metadata = new Grid.Metadata(data)

    # Detect header
    if @_metadata.hasHeader()
      headerRow = data[0]
      @_columns = headerRow
      data.splice(0, 1)
    else
      firstLetter = "A".charCodeAt(0)
      @_columns = for cell, i in data[0]
        String.fromCharCode(firstLetter + i)

    # Parse data using datatypes from metadata
    @_data = data.map (d) =>
      d.map (value, column) =>
        type = @_metadata.typeForColumn(column)
        if type == 'number'
          parseFloat(value)
        else if type == 'date'
          moment(value).toDate()
        else
          value
    # TODO: Finish up


  preview: ->
    @_data

  data: ->
    @_data


  metadata: ->
    @_metadata

  columns: ->
    @_columns

  isEmpty: ->
    @_isEmpty