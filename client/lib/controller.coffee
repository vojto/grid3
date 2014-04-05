window.Grid or= {}

assert = Grid.Util.assert

class Grid.Controller
  constructor: (template) ->
    assert(template)

    controller = @
    @events or= {}
    @helpers or= {}

    events = {}
    _.each @events, (method, key) ->
      events[key] = controller[method]

    helpers = {}
    _.each @helpers, (method, key) ->
      helpers[key] = ->
        controller[method].call(controller, @)

    _.each @actions, (method, key) ->
      events[key] = (e, template) ->
        controller[method].call(controller, @, e, template)
  
    template.events(events)
    template.helpers(helpers)

    template.rendered = ->
      controller.template = @