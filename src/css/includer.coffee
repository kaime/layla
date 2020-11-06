CSSParser      = require './parser'
SourceIncluder = require '../lib/includer/source'


###
###
class CSSIncluder extends SourceIncluder

  @EXTENSIONS: ['css']
  @PARSER: CSSParser


module.exports = CSSIncluder
