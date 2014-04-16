@Grid or= {}

assert = Grid.Util.assert

_instance = null

class Grid.SourceManager
  constructor: ->
    @_sources = {}    # Object(_id -> Object)
    @_sourceDeps = {} # Object(_id -> Dep)
    @_data = {}       # Object(_id -> Array)

    @_serverResult = null
    @_serverResultDep = new Deps.Dependency()

    @_id = Math.random()

  @instance: ->
    _instance = new Grid.SourceManager() unless _instance
    _instance

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
    sources = Sources.findArray(table.sourceIds)
    for source in sources
      @addSource(source)
      @_sourceDeps[source._id].depend()

    # Get steps to establish dependency, even if we delegate
    # the actual work to the server.
    steps = Tables.steps(table)

    # Move processing to the server side if
    # there are sources too large.
    if Meteor.isClient && _.any(sources, (s) -> s.isTooLarge)
      fromServer = @processOnServer(table, finalStep)
      return fromServer
    else
      return @processNow(table, finalStep)

  processOnServer: (table, finalStep) ->
    @_serverResultDep.depend()

    console.log 'called process, current result', @_id, @_serverResult

    if @_serverResult
      result = @_serverResult
      return result

    Meteor.call 'sources.data',
      table._id,
      finalStep._id,
      @didFinishProcessOnServer

    return null

  didFinishProcessOnServer: (err, data) =>
    console.log 'finished remote', data
    @_serverResult = data
    @_serverResultDep.changed()

    return null

  processNow: (table, finalStep) ->
    sourceIds = table.sourceIds

    # Find all the steps until upUntil
    steps = []
    for step in Tables.steps(table)
      steps.push(step)
      break if step._id == finalStep._id

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
        # Session.set('sourceError', e.message) if Session
        success = false
        currentData = new Grid.Data()
      
      return true

    # Session.set('sourceError', null) if Session && success


    currentData.data()