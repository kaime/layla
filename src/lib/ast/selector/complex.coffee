Selector = require '../selector'

class ComplexSelector extends Selector

  constructor: (@items = []) ->

  toString: ->
    (@items.map (child) -> child.toString().trim()).join ' '

  toJSON: ->
    json = super
    json.items = @items
    json

module.exports = ComplexSelector
