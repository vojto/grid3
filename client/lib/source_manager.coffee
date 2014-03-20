@Grid or= {}

class Grid.SourceManager
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
    data = @data()
    if data instanceof Array
      data.slice(0, 10)
    else
      data

  data: ->
    @_dataDep.depend()

    # Process data with steps
    steps = Steps.forSource(@source).fetch()
    currentStep = Session.get('editedObject')

    # Create Grid.Data object by sending it reference
    # to our current data array.
    data = new Grid.Data(@_data)
    success = true

    steps.every (step) ->
      try
        code = "(function(data) { #{step.code} })"
        compiled = eval(code)
        data = compiled(data)
        
      catch e
        console.log 'Failed', e.message
        console.log e
        console.log step.code
        Session.set('sourceError', e.message)
        success = false
        data = [[]]

      if currentStep && currentStep._id == step._id
        return false
      
      return true

    Session.set('sourceError', null) if success

    # Tento zazrak nam vyraba floaty pre graph.
    # Toto tu urcite nebudeme riesit, ale presunieme
    # to do kodu, ktory sa stara o pripravu dat pre
    # graf, ktory este vlastne nemame.
    
    # if !(data instanceof Array)
    #   data2 = Object.keys(data).map (k) ->
    #     [parseFloat(k), data[k]]
    #   data = data2

    data.data()