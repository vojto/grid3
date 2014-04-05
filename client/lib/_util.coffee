@Grid or= {}

class Grid.Util
  @assert: (value) ->
    if !value
      throw new Error("Expected true: #{value}")
