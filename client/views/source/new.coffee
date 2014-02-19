Template.source_new.events
  'submit form': (ev) ->
    ev.preventDefault()

    data = $(ev.currentTarget).serializeObject()

    Sources.insert data, (err) ->
      console.log 'failed', err if err
      Router.go 'home'

Template.source_new.helpers
  source: ->
    {}