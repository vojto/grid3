@Grid or= {}

assert = Grid.Util.assert

class Grid.SourceManager
  constructor: ->
    @_sources = {}    # Object(_id -> Object)
    @_sourceDeps = {} # Object(_id -> Dep)
    @_data = {}       # Object(_id -> Array)

  addSource: (source) ->
    assert source
    assert source._id

    key = source._id

    return if @_sources[key]

    @_sources[key] = source
    @_sourceDeps[key] or= new Deps.Dependency()

    if @_data[key]
      @_sourceDeps[key].changed()
      return

    if Sources.cachedRecently(source)
      # Already loaded, don't load
      @_data[key] = JSON.parse(source.cachedData)
      @_sourceDeps[key].changed()
      return

    Meteor.call 'sources.load', source._id, (err, data) =>
      @_data[key] = data
      @_sourceDeps[key].changed()

  preview: (upUntil) ->
    return [] unless upUntil
    data = @data(upUntil)
    if data instanceof Array
      data.slice(0, 10)
    else
      data

  data: (finalStep) ->
    throw new Error("No finalStep step specified") unless finalStep

    # Find table
    table = Tables.findOne(finalStep.tableId)
    return unless table

    # Prepare the sources
    sourceIds = table.sourceIds

    # Find all the steps until upUntil
    steps = []
    for step in Tables.steps(table)
      steps.push(step)
      break if step._id == finalStep._id

    # Add sources
    for source in Sources.findArray(sourceIds)
      @addSource(source)
      @_sourceDeps[source._id].depend()

    success = true

    currentData = null

    steps.every (step) =>
      # Prepare input array
      if !currentData
        # We're not processing anything, so pass data from sources.
        datas = for id in (sourceIds || [])
          new Grid.Data(@_data[id])
      else
        datas = [currentData]

      # Figure out how to pass arguments to the step
      if datas.length > 1
        argNames = (for i in [1..datas.length]
          "data#{i}").join(",")
      else
        argNames = "data"

      try
        code = "(function(#{argNames}) { #{step.code} })"
        compiled = eval(code)
        currentData = compiled.apply(this, datas)
        
      catch e
        console.log 'Failed', e.message
        console.log e
        console.log step.code
        Session.set('sourceError', e.message)
        success = false
        currentData = new Grid.Data()
      
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

    currentData.data()