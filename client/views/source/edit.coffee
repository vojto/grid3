class SourceEdit extends Grid.Controller
  actions:
    'submit form': 'save'

  save: ->
    data = $(@template.find('form')).serializeObject()

    data.cachedAt = null
    data.cachedData = null

    source = Router.getData()
    Sources.set(source._id, data, Flash.handle)

    Router.go 'home'

new SourceEdit(Template.source_edit)
