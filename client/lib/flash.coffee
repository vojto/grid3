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

    component = UI.renderWithData(Template.modal, options)
    UI.insert(component, document.body)

    @instance.component = component

    @instance.$('button').focus()

  hide: ->
    @$el.remove()
    @constructor.instance = null