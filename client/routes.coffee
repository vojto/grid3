Router.configure
  layoutTemplate: 'layout'
  disableProgressSpinner: true

Router.map ->
  @route 'home',
    path: '/'
    template: 'hack_index'
    waitOn: ->
      Meteor.subscribe('tables')
      Meteor.subscribe('table_columns')

  # Projects

  @route 'project.new',
    path: '/project/new'
    template: 'project_new'

  @route 'source.new',
    path: '/source/new'
    template: 'source_new'

  @route 'source.edit',
    path: '/source/:_id'
    template: 'source_edit'
    data: -> Sources.findOne({_id: @params._id})

  @route 'source.show',
    path: '/table/:tableId/sources/:sourceId'
    template: 'source_show'
    data: ->
      table: Tables.findOne(@params.tableId),
      source: Sources.findOne(@params.sourceId)

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

  @route 'dashboard.edit',
    path: '/dashboard/:_id/edit'
    template: 'dashboard_edit'
    data: -> Projects.findOne {id: @params._id}

  # Workflow

  @route 'table.edit',
    path: '/table/:_id'
    template: 'table_edit'
    data: -> {table: Tables.findOne(@params._id)}

  @route 'step.edit',
    path: '/table/:tableId/steps/:stepId'
    template: 'step_edit'
    data: ->
      table: Tables.findOne(@params.tableId),
      step: Steps.findOne(@params.stepId)
    waitOn: ->
      Meteor.subscribe('tables')

  @route 'graph.edit',
    path: '/table/:tableId/graphs/:graphId'
    template: 'graph_edit'
    data: ->
      table: Tables.findOne(@params.tableId),
      graph: Graphs.findOne(@params.graphId)