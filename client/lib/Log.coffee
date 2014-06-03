class @Logger
  colors:
    orange1: ["fff", "f68f16"]
    orange2: ["fff", "d77d13"]
    green0: ["28bb00"]
    green1: ["fff", "1e8f00"]
    blue1: ["fff", "165ad7"]
    red1: ["fff", "c03a3a"]
    orange0: ['fff', 'e58905']

  constructor: ({@enabled}) ->
    _(@colors).each (values, color) =>
      @[color] = () =>
        @log(arguments, values[0], values[1])

  log: (messages, fg, bg) ->
    return unless @enabled
    style = "color: ##{fg}; -webkit-border-radius: 3px;"
    style += "background-color: ##{bg}; " if bg

    args = ["%c#{messages[0]}", style]

    if messages.length > 1
      args = _(args).union(_(messages).rest())

    console.log.apply(console, args)

@Log = new Logger(enabled: true)