@Grid or= {}

class Grid.Data
  constructor: (data) ->
    @_data = data
    @config = new Grid.DataConfig(label: 0, value: 1)
    @labelParsers =
      'date.formatted': (v) -> moment(v).unix()
      'date.unix': (v) -> v

    @parse()

  parse: ->
    # Parses data using current config and returns the result
    # For now, we don't evaluate, just display the result and see what's next.

    result = []
    for d in @_data
      label = d[@config.label]
      value = d[@config.value]

      if @config.labelType
        label = @labelParsers[@config.labelType](label)

      result.push([label, value])

    result

  raw: ->
    @_data

class Grid.DataConfig
  # Configuration of data to be used for guessing structure
  constructor: (options) ->
    @label = options.label || 0
    @labelType = 'date.formatted' # or 'date.unix'
    @value = options.value || 1