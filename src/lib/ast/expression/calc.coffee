Literal = require './literal'

class Calc extends Literal

  constructor: (@value) ->

  toJSON: ->
    json = super
    json.value = @value
    json

module.exports = Calc
