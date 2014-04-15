class Grid.Metadata
  constructor: (data) ->
    console.log 'constructing metadata'

    # Take a sample of data, and find the most likely data
    # type for them.
    sample = _.sample(data, 20)

    @columns = (_.max sample, (row) -> row.length).length

    @types = for i in [0...@columns]
      columnSample = _.map sample, (row) -> row[i]
      types = _.map columnSample, @typeForValue
      counts = _.pairs(_.countBy(types))
      topPair = _.max counts, (pair) -> pair[1]
      type = topPair[0]

      type

    console.log 'types', @types

    # TODO: Integers/Floats should also be converted from strings.

  typeForValue: (value) ->
    if value == ''
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

  columnsOfPreferredTypes: (types) ->
    []