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

        addHelper = (method, key) ->
          helpers[key] = ->
            args = (a for a in arguments)
            args.unshift(@)
            controller[method].apply(controller, args)

        # Collect helpers
        if _(controller.helpers).isArray()
          _(controller.helpers).each (method) ->
            addHelper(method, method)
        else
          _(controller.helpers).each (method, key) ->
            addHelper(method, key)


        templateConstructor.helpers(helpers)

        controller.created.call(controller, @) if controller.created
      
      templateConstructor.rendered = ->
        template = @
        controller = template.controller
        controller.$el = controller.el = $(template.firstNode)
        controller.rendered.call(controller, @) if controller.rendered

      templateConstructor.destroyed = ->
        template = @
        controller = template.controller
        controller.$el = null
        controller.destroyed.call(controller, @) if controller.destroyed

    , 0

  @include: (obj) ->
    moduleKeywords = ['included', 'extended']
    throw new Error('include(obj) requires obj') unless obj
    for key, value of obj when key not in moduleKeywords
      @::[key] = value
    obj.included?.apply(this)
    this
