ComplementarySelector = require './complementary'

class PseudoSelector extends ComplementarySelector

  constructor: (name = null, @arguments = null) -> super name

  clone: (name = @name, args = @arguments, etc...) ->
    super name, args, etc...

  toString: ->
    str = @name

    if @arguments
      str += '('

      args = []

      for arg in @arguments
        args.push (arg.map (a) -> a.toString()).join ' '

      str += args.join ', '

      str += ')'

    str

  toJSON: ->
    json = super
    json.arguments = @arguments
    json

module.exports = PseudoSelector
