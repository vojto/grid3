Router.configure
  layoutTemplate: 'layout'
  disableProgressSpinner: true

Router.map ->
  @route 'home',
    path: '/'
    template: 'home.index'

  # Projects

  @route 'project.new',
    path: '/project/new'
    template: 'project_new'

  @route 'source.new',
    path: '/source/new'
    template: 'source_new'

  @route 'project.show',
    path: '/project/:_id'
    template: 'project_show'
    data: -> Projects.findOne {_id: @params._id}
    waitOn: -> @subscribe('project')
    loadingTemplate: 'loading'


  @route 'dashboard.show',
    path: '/dashboard/:_id'
    template: 'dashboard_show'
    data: -> Projects.findOne {_id: @params._id}

  @route 'flow.edit',
    path: '/flow/:_id'
    template: 'flow_edit'
    data: -> Projects.findOne {_id: @params._id}