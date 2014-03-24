@Grid or= {}

class Grid.Data
  constructor: (data) ->
    @_data = $.extend(true, [], data)

  filter: (fn) ->
    @_data = @_data.filter(fn)
    @

  group: (fields, fn) ->
    grouped = @_data.reduce (sum, d) ->
      key = fields.map((field) -> d[field]).join()  
      if !sum[key]
        sum[key] = d
      
      fn(sum[key], d)

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