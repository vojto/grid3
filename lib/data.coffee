@Grid or= {}

class Grid.Data
  constructor: (data) ->
    @_data = []
    _.extend(@_data, data)

  filter: (fn) ->
    @_data = @_data.filter(fn)
    @

  group: (fields, fn) ->
    grouped = @_data.reduce (sum, d) ->
      if _.isFunction(fields)
        sumKey = fields(d)
      else
        sumKey = fields.map((field) -> d[field]).join()  

      if !sum[sumKey]
        sum[sumKey] = d
      
      fn(sum[sumKey], d)

      sum
    , {}

    @_data = _.values(grouped)
    @

  map: (fn) ->
    @_data = @_data.map(fn)
    @

  data: ->
    @_data

  splice: (index, count) ->
    @_data.splice(index, count)
    @

  merge: (data, fn1, fn2) ->
    merged = @_data.reduce (sum, d) ->
      key = fn1(d)
      sum[key] or= []
      sum[key].push(d)
      sum
    , {}

    merged = data._data.reduce (sum, d) ->
      key = fn2(d)
      sum[key] or= []
      sum[key].push(d)
      sum
    , merged

    keys = Object.keys(merged).filter (key) ->
      d = merged[key]
      d.length == 2

    merged = keys.map (key) ->
      d = merged[key]
      d1 = d[0]
      d2 = d[1]
      return d1.concat(d2)

    @_data = merged
    @