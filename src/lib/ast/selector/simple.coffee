Selector = require '../selector'

class SimpleSelector extends Selector

  constructor: (@name, @namespace = null) ->

  toJSON: ->
    json = super
    json.name = @name
    json.namespace = @namespace
    json

module.exports = SimpleSelector
