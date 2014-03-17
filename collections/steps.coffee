@Steps = new Meteor.Collection2 "steps",
  schema:
    sourceId: { type: String }
    weight: { type: Number, label: 'Weight' }
    title: { type: String, label: 'Title', optional: true }
    code: { type: String, label: 'Code' }
    expanded: { type: Boolean, label: 'expanded', optional: true }
    x: { type: Number, label: 'X', optional: true }
    y: { type: Number, label: 'Y', optional: true }
    # disabled: { type: Boolean,}

@Steps.allow
  insert: (userId, doc) -> true
  update: (userId, doc) -> true
  remove: (userId, doc) -> true

@Steps.lastForSource = (source) ->
  Steps.findOne({sourceId: source._id}, {sort: {weight: -1}})

@Steps.forSource = (source) ->
  Steps.find({sourceId: source._id}, {sort: {weight: 1}})

@Steps.nextWeight = (source) ->
  step = Steps.lastForSource(source)
  if step
    return step.weight + 1
  else
    return 0

@Steps.DEFAULT_CODE = 'return data.map(function(d) {\n  return d;\n});'