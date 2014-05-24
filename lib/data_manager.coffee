@Grid or= {}

_instance = null

class Grid.DataManager
  @instance: ->
    _instance = new @() unless _instance
    _instance

  constructor: ->
    @_datas = {}

  dataForSource: (source) ->
    key = source._id
    if !@_datas[key]
      @_datas[key] = new Grid.Data(source)
    @_datas[key]


class Grid.Data
  constructor: (source) ->
    # TODO: Instead of expecting prepared cached data,
    # figure out the whole trip to server and caching
    # and stuff like that.
    if !source.cachedData
      @_isEmpty = true
      return

    @_data = JSON.parse(source.cachedData)
    @_metadata = new Grid.Metadata(@_data)

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

  columns: ->
    @_columns

  isEmpty: ->
    @_isEmpty