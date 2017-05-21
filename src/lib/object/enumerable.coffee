Object   = require '../object'
Iterable = require './iterable'
Null     = require './null'
Number   = require './number'

###
###
class Enumerable extends Iterable

  @property 'length',
    get: -> @NOT_IMPLEMENTED

  get: (key) -> @NOT_IMPLEMENTED

  currentValue: -> @get @currentKey()

  currentKey: -> @NOT_IMPLEMENTED

  firstKey: -> @NOT_IMPLEMENTED

  lastKey: -> @NOT_IMPLEMENTED

  hasKey: (key) -> @NOT_IMPLEMENTED

  randomKey: -> @NOT_IMPLEMENTED

  firstValue: -> @get @firstKey()

  lastValue: -> @get @lastKey()

  randomValue: -> @get @randomKey()

  minValue: ->
    min = null
    @each (i, item) ->
      min = item if min is null or (item.compare min) is 1

    return min

  maxValue: ->
    max = null
    @each (i, item) ->
      max = item if max is null or (item.compare max) is -1

    return max

  isEmpty: -> @length is 0

  isEnumerable: -> yes

  isEqual: (other) ->
    (other instanceof Enumerable) and
    (other.length is @length) and
    @each (key, value) -> value.isEqual other.get(key.value)

  '.::': @::get

  '.length': -> new Number @length

  '.first': -> @firstValue() or Null.null

  '.last': -> @lastValue() or Null.null

  '.random': -> @randomValue() or Null.null

  '.min': -> @minValue() or Null.null

  '.max': -> @maxValue() or Null.null

Object::isEnumerable = -> no


module.exports = Enumerable
