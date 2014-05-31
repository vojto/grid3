class @Logger
  colors:
    orange1: ["fff", "f68f16"]
    orange2: ["fff", "d77d13"]
    green0: ["28bb00"]
    green1: ["fff", "1e8f00"]
    blue1: ["fff", "165ad7"]

  constructor: ({@enabled}) ->
    _(@colors).each (values, color) =>
      @[color] = (message) =>
        @log(message, values[0], values[1])

  log: (message, fg, bg) ->
    return unless @enabled
    style = "color: ##{fg}; -webkit-border-radius: 3px;"
    style += "background-color: ##{bg}; " if bg
    console.log("%c#{message}", style)

@Log = new Logger(enabled: true)