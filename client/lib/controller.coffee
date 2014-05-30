window.Grid or= {}

assert = Grid.Util.assert

class Grid.Controller
  constructor: (template) ->

  $: (selector) ->
    @$el.find(selector)


  @template: (name) ->
    setTimeout =>
      constructor = @
      templateConstructor = Template[name]
      controllerPrototype = @prototype

      events = {}

      # Collect events
      _.each controllerPrototype.events, (method, key) ->
        events[key] = (e, template) ->
          controller = template.controller
          controller[method](e, template)

      # Collect actions
      _(controllerPrototype.actions).each (method, key) ->
        events[key] = (e, template) ->
          e.preventDefault()
          controller = template.controller
          controller[method].call(controller, @, e, template)

      templateConstructor.events(events)

      templateConstructor.created = ->
        template = this
        controller = new constructor
        # controller._id = "#{name} #{Math.random()}"
        
        template.controller = controller
        controller.template = template

        helpers = {}

        # Collect helpers
        if _(controller.helpers).isArray()
          _(controller.helpers).each (method) ->
            helpers[method] = -> controller[method].call(controller, @)
        else
          _(controller.helpers).each (method, key) ->
            helpers[key] = -> controller[method].call(controller, @)


        templateConstructor.helpers(helpers)
      
      templateConstructor.rendered = ->
        template = @
        controller = template.controller
        controller.$el = controller.el = $(template.firstNode)
        controller.didRender.call(controller, @) if controller.didRender  

    , 0

  @include: (obj) ->
    moduleKeywords = ['included', 'extended']
    throw new Error('include(obj) requires obj') unless obj
    for key, value of obj when key not in moduleKeywords
      @::[key] = value
    obj.included?.apply(this)
    this
