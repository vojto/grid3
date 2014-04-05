Meteor.subscribe('sources')
Meteor.subscribe('steps')
Meteor.subscribe('graphs')
Meteor.subscribe('projects')
Meteor.subscribe('tables')

window.commandPrompt = new CommandPrompt
window.context = new Context