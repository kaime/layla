Enumerable = require './enumerable'
Null       = require './null'
Number     = require './number'

###
###
class Indexed extends Enumerable

  constructor: ->
    @reset()

  reset: -> @index = 0

  keyToIndex: (key) -> key

  indexToKey: (index) -> index

  hasIndex: (key) -> 0 <= key < @length

  done: -> @index >= @length

  next: ->
    unless @done()
      return @getByIndex @index++

  firstIndex: -> if @length then 0 else null

  lastIndex: -> if 0 < (length = @length) then length - 1 else null

  currentIndex: ->
    if 0 <= @index < @length
      @index
    else
      null

  randomIndex: ->
    length = @length

    if length > 0
      return Math.floor Math.random() * length
    else
      return null

  getByIndex: @NOT_IMPLEMENTED

  hasKey: (key) ->  @hasIndex @keyToIndex(key)

  firstKey: -> @indexToKey @firstIndex()

  lastKey: -> @indexToKey @lastIndex()

  currentKey: -> @indexToKey @currentIndex()

  randomKey: -> @indexToKey @randomIndex()

  # TODO Reimplement `currentValue`, `currentValue`, `randmonValue`,
  # `firstValue` and `lastValue` using `getByIndex()` for performance reasons.

  get: (key) ->
    index = @keyToIndex(key)

    if ('number' is typeof (key + 0)) and (0 <= key < @length)
      return @getByIndex key

    return super key

  each: (cb) ->
    @reset()

    while null isnt (key = @currentKey())
      index = new Number key
      value = @get(key) or Null.null

      if no is cb.call(@, @indexToKey(index), value)
        return no

      @next()

    return yes

  '.length': -> new Number @length

  '.index': ->  Null.ifNull @currentIndex()

  '.first-index': -> Null.ifNull @firstIndex()

  '.last-index': -> Null.ifNull @lastIndex()

  '.::': (other) ->
    if other instanceof Number
      len = @length
      idx = other.value
      idx += len if idx < 0

      (@get idx) or Null.null
    else
      throw new TypeError


module.exports = Indexed
