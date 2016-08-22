ComplementarySelector = require './complementary'

class AttributeSelector extends ComplementarySelector

  constructor: (name, @value = null, @operator = '', @flags = null) ->
    super name

  toJSON: ->
    json = super
    json.value = @value
    json.operator = @operator
    json.flags = @flags
    json

module.exports = AttributeSelector
