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
        Sources.find().observeChanges
          changed: (id, fields) =>
            if fields['url']
              @reloadSource(Sources.findOne(id))

  dataForSource: (source) ->
    key = source._id
    if !@_datas[key]
      @_datas[key] = new Grid.Data(source)
    @_datas[key]

  reloadSource: (source) ->
    # Workaround for meteor not calling remote method from inside
    # this callback.
    setTimeout =>
      Sources.set(source._id, {isLoading: true})
      Meteor.call 'sources.load', source._id, (err, data) =>
        Sources.set(source._id, {isLoading: false})
        return if Flash.handle(err)
        delete @_datas[source._id]
        console.log 'finished', err, data
    , 0


class Grid.Data
  constructor: (source) ->
    # TODO: Instead of expecting prepared cached data,
    # figure out the whole trip to server and caching
    # and stuff like that.
    if !source.cachedData
      @_isEmpty = true
      return

    data = JSON.parse(source.cachedData)
    @_metadata = new Grid.Metadata(@_data)

    # Parse data using datatypes from metadata
    @_data = data.map (d) ->
      d.map (value, column) ->
        type = 
    # TODO: Finish up


    # Detect header
    if @_metadata.hasHeader()
      headerRow = @_data[0]
      @_columns = headerRow
      @_data.splice(0, 1)
    else
      firstLetter = "A".charCodeAt(0)
      @_columns = for cell, i in @_data[0]
        String.fromCharCode(firstLetter + i)

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