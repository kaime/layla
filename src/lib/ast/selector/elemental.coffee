SimpleSelector = require './simple'


###
###
class ElementalSelector extends SimpleSelector

  constructor: (name, @namespace = null) ->
    super name

  copy: (name = @name, namespace = @namespace, etc...) ->
    super name, namespace, etc...

module.exports = ElementalSelector
