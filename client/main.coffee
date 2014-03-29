Meteor.subscribe('sources')
Meteor.subscribe('steps')
Meteor.subscribe('graphs')
Meteor.subscribe('projects')

window.commandPrompt = new CommandPrompt
window.context = new Context