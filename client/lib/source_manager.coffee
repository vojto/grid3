class @SourceManager
  constructor: (source) ->
    @source = source

  loadData: (callback) ->
    if @source.cachedData
      @_data = JSON.parse(@source.cachedData)
      callback()
      return

    url = @source.url
    IronRouterProgress.start()
    Meteor.call 'sources.load', @source.url, (err, data) =>
      IronRouterProgress.done()
      Sources.update @source._id, {$set: {cachedData: JSON.stringify(data)}}
      @_data = data
      callback()

  preview: ->
    @_data

  data: ->
    new Grid.Data(@_data)