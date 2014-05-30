@Grid or= {}

_instance = null

class Grid.DataManager
  @instance: ->
    _instance = new @() unless _instance
    _instance

  constructor: ->
    @_datas = {}

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
    if !@_datas[key]
      @_datas[key] = new Grid.Data(table)
    @_datas[key]

  reloadTable: (table) ->
    # Workaround for meteor not calling remote method from inside
    # this callback.
    setTimeout =>
      Tables.set(table._id, {isLoading: true})
      # This should now look what type of table we're dealing with, and act
      # accordingly. For now we'll just assume it's a source and load it.
      Meteor.call 'sources.load', table._id, (err, data) =>
        Tables.set(table._id, {isLoading: false})
        return if Flash.handle(err)
        delete @_datas[table._id]
        console.log 'finished', err, data
    , 0


class Grid.Data
  constructor: (table) ->
    # TODO: Instead of expecting prepared cached data,
    # figure out the whole trip to server and caching
    # and stuff like that.
    if !table.cachedData
      @_isEmpty = true
      return

    data = JSON.parse(table.cachedData)
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