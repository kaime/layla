ElementalSelector = require './elemental'

class TypeSelector extends ElementalSelector

  constructor: (@name = null, etc...) -> super etc...

  clone: (name = @name, etc...) ->
    super name, etc...

  toString: ->
    if @namespace?
      str = @namespace + '|'
    else
      str = ''

    str += @name

    return str

  toJSON: ->
    json = super
    json.name = @name
    json

module.exports = TypeSelector
