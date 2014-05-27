class Grid.Metadata
  constructor: (data) ->
    # Take a sample of data, and find the most likely data
    # type for them.
    @sample = _.sample(data, 20)
    @firstRow = data[0]

    @columns = (_.max @sample, (row) -> row.length).length

    @types = for i in [0...@columns]
      columnSample = _.map @sample, (row) -> row[i]
      types = _.map columnSample, @typeForValue
      counts = _.pairs(_.countBy(types))
      topPair = _.max counts, (pair) -> pair[1]
      type = topPair[0]
      type

    # Decide if it has header
    hasHeader = false
    for type, i in @types
      firstRowType = @typeForValue(@firstRow)
      if firstRowType != type
        hasHeader = true
    @_hasHeader = hasHeader

  typeForValue: (value) ->
    if value == ''
      'string'
    else if value == null
      'string'
    else if !isNaN(value)
      'number'
    else
      # Try to parse it as a date
      date = moment(value)
      if date.isValid()
        'date'
      else
        'string'

  columnsOfPreferredTypes: (preferredTypes, options={}) ->
    columns = []
    except = options.except

    for preferredType in preferredTypes
      for type, column in @types
        if type == preferredType && !(except && column in except)
          columns.push(column)

    _.uniq(columns)


  hasHeader: ->
    @_hasHeader