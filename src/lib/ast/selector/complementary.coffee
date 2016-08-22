SimpleSelector = require './simple'

class ComplementarySelector extends SimpleSelector

  constructor: (@name = null) ->

  toJSON: ->
    json = super
    json.name = @name
    json

module.exports = ComplementarySelector
