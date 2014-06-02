class @Flash
  @handle: (err) ->
    if err
      Modal.show
        title: 'Error'
        description: err
        buttons: ['OK']
    err


class @Modal extends Grid.Controller
  @template 'modal'

  actions:
    'click button': 'hide'

  @show: (options) ->
    @instance = new Modal()
    inst = @instance

    setTimeout =>
      if options.template
        template = Template[options.template]
      else
        template = Template.modal
      
      
      component = UI.renderWithData(template, options)
      UI.insert(component, document.body)
      inst.component = component
    , 0

    inst

  rendered: ->
    @$('button').focus()

  hide: ->
    @$el.remove()
    @constructor.instance = null