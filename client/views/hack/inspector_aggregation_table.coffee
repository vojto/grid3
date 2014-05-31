class HackInspectorAggregationTable extends Grid.Controller
  @extend ItemsHelpers
  @include TableActions
  @template 'hack_inspector_aggregation_table'

  actions:
    'click .delete': 'delete'
    'click .add-aggregation': 'addAggregation'
    'click .remove-aggregation': 'removeAggregation'
    'blur form.aggregation input': 'updateAggregations'
    'change form.aggregation select': 'updateAggregations'

  @aggregations: ->
    console.log 'calling helper for aggregations'
    # We have to make sure this will be very reactive, in other words reactive as fuck
    # But I don't understand why isn't this shit reactive by default. Perhaps it's because
    # only cursors are reactive, not results of findOne, which current @data is.
    table = Session.get('selection') # This is shitty way to do this :-(
    cursor = Tables.find({_id: table._id})
    cursor.fetch()[0].aggregations

  rendered: ->
    for aggregation, i in @data.aggregations
      $form = @$('form.aggregation').eq(i)
      $form.find('select.columnIndex').val(aggregation.columnIndex)
      $form.find('select.function').val(aggregation.function)

  addAggregation: ->
    table = @data
    # Push to array
    aggregation =
      name: 'New aggregation'
      columnIndex: 0
      function: 'avg'
    Tables.update table._id, {$push: {aggregations: aggregation}}

  removeAggregation: (aggregation) ->
    table = @data
    Tables.update table._id, {$pull: {aggregations: aggregation}}

  updateAggregations: ->
    Log.blue1 'updating aggregations'
    data = for el in @$('form.aggregation')
      console.log 'checking form', el
      $(el).serializeObject()
    console.log 'data', data

    Tables.update @data._id, {$set: {aggregations: data}}