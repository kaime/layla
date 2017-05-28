BaseContext = require './base'
FSLoader    = require '../loader/fs'
CLILogger   = require '../logger/cli'


###
###
class NodeContext extends BaseContext

  constructor: ->
    super()
    @use new FSLoader
    @use new CLILogger


module.exports = NodeContext
