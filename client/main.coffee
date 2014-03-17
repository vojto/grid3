Meteor.subscribe('sources')
Meteor.subscribe('steps')
Meteor.subscribe('graphs')

window.commandPrompt = new CommandPrompt
window.context = new Context