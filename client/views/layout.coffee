Template['layout'].events
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