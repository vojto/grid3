class @SourceManager
  constructor: (source) ->
    @source = source
    @_data = null
    @_dataDep = new Deps.Dependency
    @_isLoaded = false

  loadData: (callback) ->
    if @source.cachedData
      @_data = JSON.parse(@source.cachedData)
      @_isLoaded = true
      @_dataDep.changed()
      callback() if callback
      return

    url = @source.url
    IronRouterProgress.start()
    Meteor.call 'sources.load', @source.url, (err, data) =>
      IronRouterProgress.done()
      Sources.update @source._id, {$set: {cachedData: JSON.stringify(data)}}
      @_data = data
      @_processedData = null
      @_isLoaded  = true
      @_dataDep.changed()
      callback() if callback

  preview: ->
    @_dataDep.depend()

    # Process data with steps
    steps = Steps.forSource(@source)
    data = $.extend(true, [], @_data);
    success = true
    steps.forEach (step) ->
      try
        code = "(function(data) { #{step.code} })"
        compiled = eval(code)
        data = compiled(data)
        
      catch e
        console.log 'Failed', e.message
        console.log e
        console.log step.code
        success = false
        data = [[]]
    
    if data instanceof Array
      data.slice(0, 100)

    data