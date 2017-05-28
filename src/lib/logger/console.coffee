Logger = require '../logger'

###
###
class ConsoleLogger extends Logger

  log: (message, level = Logger.INFO) ->
    # coffeelint: disable=no_debugger
    console.error message


module.exports = ConsoleLogger
