window.Grid or= {}

assert = Grid.Util.assert

class Grid.Controller
  constructor: (template) ->
    assert(template)

    @events or= {}
    @helpers or= {}

    events = {}
    for key, method of @events
      events[key] = @[method]

    helpers = {}
    for key, method of @helpers
      helpers[key] = @[method]

    template.events(events)
    template.helpers(helpers)