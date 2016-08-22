Expression = require '../expression'

class Operation extends Expression

  constructor: (@operator, @left = null, @right = null) ->

  @property 'unary',
    get: -> not (@left and @right)

  @property 'binary',
    get: -> @left and @right and yes

  toJSON: ->
    json = super
    json.operator = @operator
    json.left = @left
    json.right = @right
    json

module.exports = Operation
