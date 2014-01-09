prompt = null

shortenURL = (url) ->
  part1 = url.split('://')[1]
  part1.split('/')[0] if part1

class @CommandPrompt
  constructor: ->
    @name = 'Dave'
    @sound = new Audio('/beep.mp3');

    @setMessage("Hello, #{@name}. Please paste a URL of your data source.")

    # commands
    @commands =
      addSource: new AddSourceCommand

    prompt = @

  setMessage: (message) ->
    Session.set('message', message)

  processCommand: (command) ->
    @sound.play()

    if @nextHandler
      @nextHandler(command)
      @nextHandler = null
    else if command.substring(0, 4) == 'http'
      @commands.addSource.run(command)
    else
      @setMessage('Okay, Dave.')

  next: (handler) ->
    @nextHandler = handler


class AddSourceCommand
  run: (command) ->
    IronRouterProgress.start()

    title = shortenURL(command)
    Sources.insert {url: command, title: title}, (err, res) =>
      alert 'Failed creating source' if err
      IronRouterProgress.done()

      prompt.setMessage("What should I call the source at #{command}?")
      prompt.next(@setName.bind(@))

      @sourceID = res
      console.log 'setting id', @sourceID

  setName: (command) ->
    console.log 'setting name to', command, @sourceID
    Sources.update @sourceID, {$set: {title: command}}, (err, res) ->
      console.log err, res
    prompt.setMessage("Okay. Created source called #{command}.")