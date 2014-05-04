class SourceShow extends Grid.Controller
  didRender: ->
    manager = null
    Deps.autorun ->
      source = Router.getData().source
      return unless source
      manager = Grid.SourceManager.instance() unless manager
      manager.addSource(source)
      # well we don't have the finalStep to pass to manager :-/
      console.log 'lol'
      preview = []
      Session.set('preview', preview)

new SourceShow(Template.source_show)