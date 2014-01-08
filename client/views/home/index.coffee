Template['home.index'].events
  'submit form': (ev) ->
    ev.preventDefault()

    $form = $(ev.currentTarget)
    data = $form.serializeObject()
    $form.find('input').val('')

    # Create the source
    IronRouterProgress.start()
    Sources.insert {url: data.url}, (err, res) ->
      alert 'Failed creating sources' if err
      IronRouterProgress.done()

  'click i.delete': (ev) ->
    console.log 'deleting', @
    Sources.remove {_id: @_id}, (err, res) ->
      console.log 'removed', err, res

  'click i.link': (ev) ->
    console.log 'opening', @
    Router.go 'source.show', @

Template['home.index'].helpers
  sources: ->
    Sources.find {}

  shortenURL: (url) ->
    part1 = url.split('://')[1]
    part1.split('/')[0] if part1