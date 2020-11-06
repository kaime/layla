SourceIncluder = require './source'
LayParser      = require '../parser/lay'


###
###
class LayIncluder extends SourceIncluder

  @EXTENSIONS: ['lay', '']
  @PARSER: LayParser


module.exports = LayIncluder
