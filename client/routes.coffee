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

  # This is temporarily (maybe permanently disabled), because we're
  # moving this interface to `step.edit`.
  #
  # @route 'project.show',
  #   path: '/project/:_id'
  #   template: 'project_show'
  #   data: -> Projects.findOne {_id: @params._id}
  #   waitOn: -> @subscribe('project')
  #   loadingTemplate: 'loading'

  @route 'project.show',
    path: '/project/:_id'
    template: 'project_show'
    data: -> Projects.findOne({_id: @params._id})

  @route 'flow.edit',
    path: '/flow/:_id'
    template: 'flow_edit'
    data: -> Projects.findOne {_id: @params._id}

  @route 'dashboard.show',
    path: '/dashboard/:_id'
    template: 'dashboard_show'
    data: -> Projects.findOne {_id: @params._id}

  # Workflow

  @route 'table.edit',
    path: '/table/:_id'
    template: 'table_edit'
    data: -> Tables.findOne(@params._id)

  @route 'step.edit',
    path: '/table/:tableId/steps/:stepId'
    template: 'step_edit'
    data: ->
      {
        table: Tables.findOne(@params.tableId)
        step: Steps.findOne(@params.stepId)
      }
    waitOn: ->
      Meteor.subscribe('tables')