class HackInspectorAggregationTable extends Grid.Controller
  @extend ItemsHelpers
  @include TableActions
  @template 'hack_inspector_aggregation_table'

  actions:
    'click .delete': 'delete'
