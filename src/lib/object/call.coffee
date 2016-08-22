Object = require '../object'

class Call extends Object

  constructor: (@name, @arguments = []) ->

  toJSON: ->
    json = super
    json.name = @name
    json.arguments = @arguments
    json

module.exports = Call
