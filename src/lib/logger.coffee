Plugin = require './plugin'

###
###
class Logger extends Plugin

  @DEBUG   = 10
  @INFO    = 20
  @NOTICE  = 30
  @WARNING = 40
  @ERROR   = 50

  ###
  ###
  log: (message, level) -> @class.NOT_IMPLEMENTED()

  ###
  ###
  use: (context) ->
    context.useLogger @


module.exports = Logger
