Template.layout.events
  'click button.dashboard': ->
    source = Sources.findOne()
    if source
      Router.go 'dashboard.show', source
    else
      alert 'No documents'