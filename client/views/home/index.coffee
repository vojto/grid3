Template['home.index'].events
  'click i.delete': (ev) ->
    Sources.remove {_id: @_id}, (err, res) ->
      console.log 'removed', err, res

  'click i.text-doc': (ev) ->
    Router.go 'source.show', @

  'click li.add-document': (ev) ->
    Router.go 'source.new'


Template['home.index'].helpers
  sources: ->
    Sources.find {}

  shortenURL: (url) ->
    part1 = url.split('://')[1]
    part1.split('/')[0] if part1