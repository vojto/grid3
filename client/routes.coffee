Router.configure
  layoutTemplate: 'layout'
  disableProgressSpinner: true

Router.map ->
  @route 'home',
    path: '/'
    template: 'home.index'

  @route 'source.new',
    path: '/source/new'
    template: 'source_new'

  @route 'source.show',
    path: '/source/:_id'
    template: 'source_show'
    data: -> Sources.findOne {_id: @params._id}

  @route 'dashboard.show',
    path: '/dashboard/:_id'
    template: 'dashbaord_show'
    data: -> Sources.findOne {_id: @params._id}