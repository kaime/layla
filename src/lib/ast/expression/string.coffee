Literal = require './literal'


###
###
class String extends Literal

  constructor: (@value, @quote = null, @raw = no) ->
    super()

  append: (str) ->
    if @value instanceof Array
      @value.push str
    else
      @value += str

  prepend: (str) ->
    if @value instanceof Array
      @value.unshift str
    else
      @value = str + @value


module.exports = String
