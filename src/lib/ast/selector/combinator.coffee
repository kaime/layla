Selector = require '../selector'

class Combinator extends Selector

  constructor: (@value = null) ->

  toString: -> @value or ''

  toJSON: ->
    json = super
    json.value = @value
    json

module.exports = Combinator
