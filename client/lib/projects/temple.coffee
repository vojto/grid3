###
This is a temporary file, for our code-only approach. Later, we'll move the
contents of this file to the database, later maybe break it up into pieces,
but for now, we just want to use it to build a set of APIs to build cool things
with.
###

class TempleProject
  constructor: ->
    # Create the source
    url = 'http://rinik.net/data/calories.csv'

    Meteor.call 'sources.loadUrl', url, (err, data) ->
      console.log 'heres the resulting data', data

      $el = $('.dashboard')
      width = $el.width()
      height = 300

      svg = d3.select($el.get(0)).append('svg')
        .attr('class', 'chart')
        .attr('width', width)
        .attr('height', height)


window.ProjectsCode or= {}
window.ProjectsCode['Temple'] = TempleProject