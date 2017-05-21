Indexed   = require './indexed'
Boolean   = require './boolean'
Number    = require './number'
Null      = require './null'
TypeError = require '../error/type'


###
###
class Collection extends Indexed

  constructor: (@items = []) -> super()

  @property 'length',
    get: -> @items.length

  getByIndex: (index) -> @items[index]

  accept: (obj) -> obj.clone()

  splice: (start, count, objs...) ->
    objs = (@accept(obj) for obj in objs)
    @items.splice start, count, objs...

    return objs

  push: (objs...) ->
    @splice @length, 0, objs...
    return objs.pop()

  slice: (start, end) -> @items.slice start, end

  contains: (other) -> @items.some other.isEqual.bind(other)

  isUnique: ->
    for a, i in @items
      for b, j in @items
        if i isnt j and a.isEqual(b)
          return no

    return yes

  toJSON: ->
    json = super
    json.data = @items

    return json

  clone: (items = @items, etc...) ->
    super (obj.clone() for obj in items), etc...

  '.+': (other) ->
    if other instanceof Collection
      return @clone @items.concat other.items

    throw new TypeError "Cannot sum collection with that"

  '.::': (other) ->
    if other instanceof Number
      idx = other.value
      idx += @items.length if idx < 0

      if 0 <= idx < @items.length
        return @items[idx]
      else
        return Null.null

    else if other instanceof Collection
      slice = @clone []

      for idx in other.items
        slice.push @['.::'](idx)

      return slice

    throw new TypeError "Bad member: #{other.type}"

  '.::=': (key, value) ->
    if key instanceof Number
      idx = key.value
      idx += @items.length if idx < 0

      if 0 <= idx <= @items.length
        return @items[idx] = value

    throw new TypeError

  '.push': (args...) -> @push args...; @

  '.pop': -> @items.pop() or Null.null

  '.shift': -> @items.shift() or Null.null

  '.unshift': (objs...) ->
    @items.unshift (obj.clone() for obj in objs)...

    return @

  '.slice': (start = Number.ZERO, end = Null.null) ->
    unless start instanceof Number and start.isPure()
      throw new Error "Bad arguments for `.slice`"

    if end.isNull()
      end = new Number @items.length

    unless end instanceof Number and end.isPure()
      throw new Error "Bad arguments for `.slice`"

    return @clone @slice(start.value, end.value)

  # TODO
  # '.splice': (start, count, objs...) ->
  # And implement it on `::=` with ranges:
  #
  # ```
  # $l = 1, 2, 3, 4, 5
  # $l::(1..3) = '...'
  # // 1, '...', 5

  '.empty': -> @items = []; @

  '.unique?': -> Boolean.new @isUnique()


module.exports = Collection
