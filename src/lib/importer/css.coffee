SourceImporter = require './source'
CSSParser      = require '../parser/css'
Evaluator      = require '../evaluator'

class CSSImporter extends SourceImporter

  parse: (source) ->
    (new CSSParser).parse source

module.exports = CSSImporter
