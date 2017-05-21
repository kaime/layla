Collection = require './collection'
Object     = require '../object'
Boolean    = require './boolean'
String     = require './string'
Number     = require './number'


class List extends Collection

  constructor: (items, @separator = ' ') -> super items

  flattenItems: ->
    flat = []

    for item in @items
      if item instanceof List
        flat.push item.flattenItems()...
      else
        flat.push item

    return flat

  clone: (items, separator = @separator, etc...) ->
    super items, separator, etc...

  toJSON: ->
    json = super
    json.separator = @separator
    json

  '.commas': -> @clone null, ','

  '.spaces': -> @clone null, ' '

  '.list': -> @clone()

  '.flatten': -> @clone @flattenItems()

  '.unique': ->
    unique = []

    @items.filter (item) ->
      for val in unique
        if val.isEqual item
          return no

      unique.push item
      return yes

    return @clone unique

Object::['.list'] = ->
  if @ instanceof Collection
    new List @items
  else
    new List [@]


module.exports = List
