class @SourceManager
  constructor: (source) ->
    @source = source

  loadData: (callback) ->
    # if @source.cachedData
    #   @data = JSON.parse(@source.cachedData)
    #   callback()
    #   return

    url = @source.url
    IronRouterProgress.start()
    Meteor.call 'sources.load', @source.url, (err, data) =>
      IronRouterProgress.done()
      Sources.update @source._id, {$set: {cachedData: JSON.stringify(data)}}
      @_data = data
      callback()

  preview: ->
    @_data.slice(0, 5)

  data: ->
    new Grid.Data(@_data)