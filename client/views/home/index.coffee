Template['home.index'].events
  'click i.delete': (ev) ->
    Sources.remove {_id: @_id}, Flash.handle
    Projects.remove {_id: @_id}, Flash.handle

  'click i.text-doc': (ev) ->
    Router.go 'source.edit', @

  'click li.add-document': (ev) ->
    Router.go 'source.new'

  'click li.add-project': (ev) ->
    Router.go 'project.new'


Template['home.index'].helpers
  sources: ->
    Sources.find {}

  shortenURL: (url) ->
    part1 = url.split('://')[1]
    part1.split('/')[0] if part1

Template.home_index_projects.events
  'click li': (ev) ->
    Router.go 'project.show', @

Template.home_index_projects.helpers
  projects: ->
    Projects.find({})