Template.source_new.events
  'submit form': (ev) ->
    ev.preventDefault()

    data = $(ev.currentTarget).serializeObject()
    Sources.insert data, Flash.handle

    if next = sessionRemove('nextUrl')
      Router.go(next)
    else
      Router.go(home)

Template.source_new.helpers
  source: ->
    {}