@Graphs = new Meteor.Collection2 'graphs',
  schema:
    collection: { type: String, autoValue: -> 'graphs' }
    projectId: { type: String }
    tableId: { type: String, optional: true }
    title: { type: String, label: 'Title', optional: true }
    code: { type: String, label: 'Code' }
    x: { type: Number, label: 'X', optional: true }
    y: { type: Number, label: 'Y', optional: true }

@Graphs.allow
  insert: (userId, doc) -> true
  update: (userId, doc) -> true
  remove: (userId, doc) -> true

@Graphs.forProject = (project) ->
  Graphs.find({projectId: project._id})

Graphs.LINE_CHART_CODE = """
var line = d3.svg.line()
    .interpolate('basis')  
    .x(function(d) { return x(d[0]) })
    .y(function(d) { return y(d[1]) });

svg.append('path')
    .attr('class', 'line')  
    .attr('d', line(data));
"""

Graphs.BAR_CHART_CODE = """
var width = svg.attr('width') / data.length;
var barWidth = width;
var height = svg.attr('height');

svg.selectAll('rect')
  .data(data)
  .enter()
  .append('rect')
  .attr('width', barWidth)
  .attr('height', function(d) { return height-y(d[1])-30 })
  .attr('x', function(d) { return x(d[0]) })
  .attr('y', function(d) { return y(d[1]) });
"""

Graphs.DEFAULT_CODE =
  line: Graphs.LINE_CHART_CODE
  bar: Graphs.BAR_CHART_CODE