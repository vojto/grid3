Template['home.index'].events
  'submit form': (ev) ->
    ev.preventDefault()

    $form = $(ev.currentTarget)
    $form.find('input').val('')

    IronRouterProgress.start()

    setTimeout ->
      IronRouterProgress.done()
    , 1000