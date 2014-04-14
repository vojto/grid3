Template.source_new.events
  'submit form': (ev) ->
    ev.preventDefault()

    data = $(ev.currentTarget).serializeObject()

    Sources.insert data, Flash.handle

Template.source_new.helpers
  source: ->
    {}