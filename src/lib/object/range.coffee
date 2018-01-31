Decimal        = require 'decimal.js'

Indexed        = require './indexed'
Null           = require './null'
Boolean        = require './boolean'
List           = require './list'
Number         = require './number'
String         = require './string'
UnquotedString = require './string/unquoted'
ValueError     = require '../error/value'


###
###
class Range extends Indexed

  { min, max, abs, floor } = Math

  @property 'items',
    get: ->
      items = []

      for i in [0...@length()]
        items.push new Number (@getByIndex i), @unit

      return items

  isReverse: -> @first.gt(@last)

  length: -> @last.sub(@first).abs().div(@step).floor().add(1)

  minValue: -> new Number Decimal.min(@first, @last), @unit

  maxValue: -> new Number Decimal.max(@first, @last), @unit

  getByIndex: (index) ->
    step = @step

    if @isReverse()
      step = step.times(-1)

    return new Number @first.add(step.times(index)), @unit

  constructor: (first = 0, last = 0, @unit = null, step = 1) ->
    @first = Decimal(first)
    @last = Decimal(last)
    @step = Decimal(step)

    super

  convert: (unit) ->
    unit = unit.toString()

    if unit isnt ''
      first = Number.convert @first, @unit, unit
      last = Number.convert @last, @unit, unit
      step = Number.convert @step, @unit, unit
    else
      unit = ''

    return @copy first, last, unit, step

  ###
  TODO this is buggy
  ###
  contains: (other) ->
    try
      other = other.convert @unit
      min = Decimal.min(@first, @last)
      max = Decimal.max(@first, @last)

      return min.lte(other._value) and other._value.lte(max)

    return no

  isPure: -> not @unit

  clone: -> @

  copy: (first = @first, last = @last, unit = @unit, step = @step, etc...) ->
    super first, last, unit, step, etc...

  reprValue: -> "#{@first.toString()}..#{@last.toString()}"

  './': (context, step) ->
    if step instanceof Number
      return @copy null, null, null, step.convert(@unit)._value

    throw new ValueError "Cannot divide a range by #{step.repr()}"

  '.unit': ->
    if @unit then new UnquotedString @unit else Null.null

  '.unit?': ->
    Boolean.new @unit

  '.pure?': ->
    Boolean.new @isPure()

  '.pure': ->
    @copy null, null, ''

  '.step': ->
    new Number @step, @unit

  '.convert': (context, args...) ->
    @convert args...

  '.reverse?': ->
    Boolean.new @isReverse()

  '.reverse': ->
    @copy @last, @first

  '.list': ->
    new List @items

Number::['...'] = (context, other) ->
  if other instanceof Number
    if @unit
      other = other.convert @unit
      unit = @unit
    else if other.unit
      unit = other.unit
    else
      unit = null

    return new Range @value, other._value, unit

  throw new ValueError "Cannot make a range with that: #{other.type}"

do ->
  supah = List::['.::']

  List::['.::'] = (context, other, etc...) ->
    if other instanceof Range
      slice = @copy []
      for idx in other.items
        slice.items.push @['.::'] context, idx
      slice
    else
      supah.call @, context, other, etc...

do ->
  { min, max } = Math

  supah = String::['.::']

  String::['.::'] = (context, other, etc...) ->
    if other instanceof Range
      str = ''

      if @value isnt ''
        len = @value.length

        end = other.last.add(1)
        if end.lt(0)
          end = end.add(len)
        end = Decimal.min(end, len - 1)

        idx = other.first
        if idx.lt(0)
          idx = idx.add(len)

        idx = Decimal.max(-len, idx)

        until idx.equals(end)
          str += @value.charAt idx.toString()
          idx = idx.add(1).mod(len)

      @copy str
    else
      supah.call @, context, other, etc...


module.exports = Range
