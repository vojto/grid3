window.Grid or= {}

assert = Grid.Util.assert

class Grid.Controller
  constructor: (template) ->
    controller = @
    @events or= {}
    @helpers or= {}

    events = {}
    _.each @events, (method, key) ->
      events[key] = controller[method]

    helpers = {}
    if _.isArray @helpers
      _(@helpers).each (method) ->
        helpers[method] = -> controller[method].call(controller, @)
    else
      _(@helpers).each (method, key) ->
        helpers[key] = -> controller[method].call(controller, @)

    _.each @actions, (method, key) ->
      events[key] = (e, template) ->
        e.preventDefault()
        controller[method].call(controller, @, e, template)

    @eventsForTemplate = events
    @helpersForTemplate = helpers
  
    if template
      @addTemplate(template)
    else if @template
      @addTemplate(Template[@template])

  $: (selector) ->
    @$el.find(selector)

  addTemplate: (template) ->
    assert(template)

    controller = @

    template.events(@eventsForTemplate)
    template.helpers(@helpersForTemplate)

    template.rendered = ->
      # Set the first template
      controller.template = @
      controller.$el = controller.el = $(@firstNode)
      # Set all templates

      controller.didRender.call(controller, @) if controller.didRender

  @template: (template) ->
    setTimeout =>
      @instance = new @(Template[template])
    , 0

  @include: (obj) ->
    moduleKeywords = ['included', 'extended']
    throw new Error('include(obj) requires obj') unless obj
    for key, value of obj when key not in moduleKeywords
      @::[key] = value
    obj.included?.apply(this)
    this