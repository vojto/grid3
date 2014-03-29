Template.project_new.events
  'submit form': (ev) ->
    ev.preventDefault()
    data = $(ev.currentTarget).serializeObject()
    Projects.insert data, Flash.handle
    Router.go 'home'

Template.project_new.helpers
  project: -> {}