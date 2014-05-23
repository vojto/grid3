class HackIndex extends Grid.Controller
  helpers:
    'sources': 'sources'

  didRender: ->
    controller = @
    Template.source.rendered = ->
      console.log 'rendered', this.firstNode
      $(@firstNode).draggable(stop: controller.didStopDragging)
      # $(@template.find('div.source')).draggable({stop: @didStopDragging})

  sources: ->
    Sources.find().fetch()

  didStopDragging: (ev) =>
    $el = $(ev.target)
    id = $el.attr('data-id')
    pos = $el.position()
    x = pos.left
    y = pos.top

    console.log 'updating', id, {x: x, y: y}
    Sources.set id, {x: x, y: y}

new HackIndex(Template.hack_index)

class Source extends Grid.Controller
  helpers:
    'sourceStyle': 'sourceStyle'

  sourceStyle: (source) ->
    "left: #{source.x||10}px; top: #{source.y||60}px;"


new Source(Template.source)