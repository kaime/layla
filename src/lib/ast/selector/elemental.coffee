SimpleSelector = require './simple'

class ElementalSelector extends SimpleSelector

  toJSON: ->
    json = super
    json.namespace = @namespace
    json

module.exports = ElementalSelector
