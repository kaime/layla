Enumerable = require './enumerable'
Null       = require './null'
Number     = require './number'


###
###
class Indexed extends Enumerable

  reset: -> @index = 0

  firstKey: -> if @length() then 0 else null

  lastKey: -> if 0 < (length = @length()) then length - 1 else null

  hasKey: (key) -> 0 <= key < @length()

  currentKey: ->
    if 0 <= @index < @length()
      @index
    else
      null

  randomKey: ->
    length = @length()

    if length > 0
      Math.floor Math.random() * length
    else
      null

  next: ->
    if 0 <= @index <= @length()
      @index++

  getByIndex: @NOT_IMPLEMENTED

  get: (key) ->
    if ('number' is typeof (key + 0)) and (0 <= key < @length())
      return @getByIndex key
    else
      return null

  each: (cb) ->
    @reset()

    while null isnt (key = @currentKey())
      index = Number.new key
      value = Null.ifNull @get(key)

      if no is cb.call(@, index, value)
        return no

      @next()

  '.index': ->  Null.ifNull @currentKey()

  '.first-index': -> Null.ifNull @firstKey()

  '.last-index': -> Null.ifNull @lastKey()

  '.::': (context, other) ->
    if other instanceof Number
      len = @length()
      idx = other.value
      idx += len if idx < 0

      return Null.ifNull @get(idx)

    return super context, other


module.exports = Indexed
