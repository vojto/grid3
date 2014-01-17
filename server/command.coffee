Meteor.methods
  'command.setMessage': (message) ->
    exec = Npm.require('child_process').exec
    exec "say #{message}"