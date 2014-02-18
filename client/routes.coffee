Router.configure
  layoutTemplate: 'layout'
  disableProgressSpinner: true

Router.map ->
  @route 'home',
    path: '/'
    template: 'home.index'

  @route 'source.show',
    path: '/source/:_id'
    template: 'source_show'
    data: ->
      Sources.findOne {_id: @params._id}