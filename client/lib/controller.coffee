window.Grid or= {}

assert = Grid.Util.assert

class Grid.Controller
  constructor: (template) ->
    assert(template)

    controller = @
    @events or= {}
    @helpers or= {}

    events = {}
    for key, method of @events
      events[key] = @[method]

    helpers = {}
    for key, method of @helpers
      helpers[key] = ->
        controller[method].call(controller, @)

    for key, method of @actions
      events[key] = (e, template) ->
        controller[method].call(controller, @, e, template)
  
    template.events(events)
    template.helpers(helpers)

    template.rendered = ->
      controller.template = @