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
    @_data = JSON.parse(source.cachedData)
    @_metadata = new Grid.Metadata(@_data)

    if @_metadata.hasHeader()
      @_data.splice(0, 1)

  preview: ->
    @_data