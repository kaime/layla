Object = require '../object'
Logger = require '../logger'
Null   = require './null'


###
###
class Console extends Object

  ###
  ###
  LEVELS = [
    'debug'
    'info'
    'notice'
    'warning'
    'error'
  ]

  ###
  ###
  log: (context, message, level) ->
    context.log message, level

  ###
  ###
  '.log': (context, message, level = Logger.DEBUG) ->
    @log context, message.toString(), level

    return Null.null

  LEVELS.forEach (name) =>
    NAME = name.toUpperCase()
    level = new Number Logger[NAME]

    ###
    ###
    @[".#{NAME}"] = -> level

    ###
    ###
    @::[".#{name}"] = (context, message) ->
      @['.log'] context, message, level


module.exports = Console
