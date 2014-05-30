@Tables = new Meteor.Collection2 "tables",
  schema:
    collection: { type: String, autoValue: -> 'tables' }
    type:       { type: String }
    projectId:  { type: String, optional: true }
    title:      { type: String, label: 'Title', optional: true }
    url:        { type: String, label: 'URL', optional: true }
    cachedData: { type: String, label: 'Cached data', optional: true }
    cachedAt:   { type: Date, optional: true }
    isTooLarge: { type: Boolean, optional: true }
    x: { type: Number, label: 'X', optional: true }
    y: { type: Number, label: 'Y', optional: true }
    width: { type: Number, optional: true }
    height: { type: Number, optional: true }
    isLoading: { type: Boolean, optional: true }
    inputTableId: { type: String, optional: true }

    # *Table
    columnIds:    { type: [String] }

    # Grouped Table
    groupColumnIndex: { type: Number, optional: true }

Tables.SOURCE = 'source'
Tables.GROUPED = 'grouped'

@Tables.allow
  insert: (userId, doc) -> true
  update: (userId, doc) -> true
  remove: (userId, doc) -> true

@Tables.isA = (obj) ->
  return obj.cachedData

@Tables.forProject = (project) ->
  Tables.find()

@Tables.cachedRecently = (table) ->
  return false unless table.cachedAt
  return false unless table.cachedData

  difference = (new Date() - table.cachedAt)/1000

  return difference < 1200


@TableColumns = new Meteor.Collection2 "table_columns",
  schema:
    collection: { type: String, autoValue: -> 'table_columns' }
    title:      { type: String }
    type:       { type: String }

@TableColumns.allow
  insert: (userId, doc) -> true
  update: (userId, doc) -> true
  remove: (userId, doc) -> true