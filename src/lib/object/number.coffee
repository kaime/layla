Decimal    = require 'decimal.js'

Object     = require '../object'
Boolean    = require './boolean'
ValueError = require '../error/value'

FACTORS = {}

###
###
class Number extends Object

  {round, ceil, floor, abs, pow, sin, cos, tan, asin, acos, atan} = Math

  RE_NUMERIC = /^\s*([\+-]?(?:\d*\.)?\d+)\s*(%|(?:[a-z]+))?\s*$/i

  @define: (from, to) ->
    unless from instanceof Number
      from = @fromString from

    unless to instanceof Number
      to = @fromString to

    if from.unit and to.unit
      if from.unit isnt to.unit
        FACTORS[from.unit] ?= {}
        FACTORS[from.unit][to.unit] = to._value.div(from._value)

        FACTORS[to.unit] ?= {}
        FACTORS[to.unit][from.unit] = from._value.div(to._value)

      else if not from.equals(to)
        throw new ValueError "Bad unit definition"

      return to

    throw new ValueError "Bad unit definition"

  @isDefined: (unit) -> unit of FACTORS

  @fromString: (str) ->
    try
      str = str.toString()
      if match = RE_NUMERIC.exec str
        value = parseFloat match[1]
        unit = match[2]
        return new Number value, unit

    throw new ValueError "Could not convert \"#{str}\" to #{@reprType()}"

  constructor: (value = 0, @unit = null) ->
    @value = parseFloat value.toString()
    @_value = new Decimal @value

  @convert: (value, from_unit, to_unit = '', stack = []) ->
    if to_unit is from_unit or (to_unit and not from_unit)
      return value
    else if not to_unit
      return value
    else if from_unit of FACTORS
      if to_unit of FACTORS[from_unit]
        return FACTORS[from_unit][to_unit].times(value)
      else
        stack.push from_unit

        for u of FACTORS[from_unit]
          unless u in stack
            stack.push u
            val = FACTORS[from_unit][u].times(value)
            try
              return @convert val, u, to_unit, stack
            stack.pop()

        stack.pop()

    throw new ValueError "Cannot convert #{value}#{from_unit} to #{to_unit}"

  ###
  ###
  convert: (unit = null) ->
    if unit
      unit = unit.toString().trim()

    value = @class.convert @_value, @unit, unit

    return @copy value, unit or ''

  ###
  ###
  negate: -> @copy @_value.times(-1)

  negative: -> @copy @_value.abs().times(-1)

  ###
  ###
  isEqual: (other) ->
    if other instanceof Number
      try
        return other.convert(@unit)._value.equals(@_value)

    return no

  compare: (other) ->
    if other instanceof Number
      other = other.convert @unit
      if other._value.equals @_value
        return 0
      else if other._value.greaterThan @_value
        return 1
      else
        return -1

    throw new ValueError (
      """
      Cannot compare #{@repr()} with #{other.repr()}: \
      that's not a [Number]
      """
    )

  isPure: -> not @unit

  isDimension: -> not @isPure()

  parity: -> @_value.mod(2).isZero()

  isInteger: -> @_value.isInteger()

  isEmpty: -> @_value.isZero()

  isPositive: -> @_value.gt(0)

  isNegative: -> @_value.lt(0)

  # http://www.javascripter.net/faq/numberisprime.htm
  isPrime: ->
    n = @value

    if n < 2 or n % 1
      return no

    if not (n % 2)
      return n is 2

    if not (n % 3)
      return n is 3

    i = 5
    m = Math.sqrt n

    while i <= m
      if not (n % i)
        return no

      if not (n % (i + 2))
        return no

      i += 6

    return yes

  toNumber: -> @clone()

  toString: -> "#{@_value.toString()}#{@unit or ''}"

  toJSON: ->
    json = super
    json.value = @value
    json.unit = @unit

    return json

  reprValue: -> @toString()

  clone: -> @

  copy: (value = @_value, unit = @unit) ->
    super value, unit

  ZERO = @ZERO = new @ 0
  TWO  = @TWO  = new @ 2
  TEN  = @TEN  = new @ 10
  ONE_HUNDRED_PERCENT = @ONE_HUNDRED_PERCENT = new @ 100, '%'
  FIFTY_PERCENT = @FIFTY_PERCENT = new @ 50, '%'
  TEN_PERCENT = @TEN_PERCENT = new @ 10, '%'

  '.+@': -> @clone()

  '.-@': -> @negate()

  '.+': (context, other) ->
    if other instanceof Number
      value = @convert(other.unit)._value.add(other._value)
      unit = other.unit or @unit

      return @copy value, unit

    throw new ValueError (
      """
      Cannot perform #{@repr()} + #{other.repr()}: \
      right side must be a #{Number.repr()}
      """
    )

  '.-': (context, other) ->
    if other instanceof Number
      value = @convert(other.unit)._value.sub(other._value)
      unit = other.unit or @unit

      return @copy value, unit

    throw new ValueError (
      """
      Cannot perform #{@repr()} - #{other.repr()}: \
      right side must be a #{Number.repr()}
      """
    )

  '.*': (context, other) ->

    if other instanceof Number
      if @isPure() or other.isPure()
        value = @._value.times(other._value)
        unit = other.unit or @unit

        return @copy value, unit

      throw new ValueError """
        Cannot perform #{@repr()} * #{other.repr()}
        """

    throw new ValueError """
      Cannot perform #{@repr()} * #{other.repr()}: \
      right side must be a #{Number.repr()}
      """

  './': (context, other) ->
    if other instanceof Number
      if other._value.isZero()
        throw new ValueError 'Cannot divide by 0'
      if !@isPure() and !other.isPure()
        value = @_value.div(other.convert(@unit)._value)
        unit = ''
      else
        value = @_value.div(other._value)
        unit = @unit or other.unit

      return @copy value, unit

    throw new ValueError (
      """
      Cannot perform #{@repr()} / #{other.repr()}: \
      right side must be a #{Number.repr()}
      """
    )

  '.unit?': -> Boolean.new not @isPure()

  '.dimension?': -> Boolean.new @isDimension()

  '.pure?': -> Boolean.new @isPure()

  '.pure': -> new Number @_value

  '.zero?': -> Boolean.new @_value.isZero()

  '.integer?': -> Boolean.new @isInteger()

  '.decimal?': -> Boolean.new not @isInteger()

  '.divisible-by?': (context, other) ->
    unless other.isPure()
      try
        other = other.convert @unit
      catch
        return Boolean.false

    return Boolean.new @_value.mod(other._value).isZero()

  '.even?': -> Boolean.new @parity()

  '.odd?': -> Boolean.new not @parity()

  '.sign': ->
    if @_value.isZero()
      sign = 0
    else if @_value.greaterThan(0)
      sign = 1
    else
      sign = -1

    return @copy sign, ''

  '.positive?': -> Boolean.new @isPositive()

  '.positive': -> @copy @_value.abs()

  '.negative': -> @negative()

  '.negate': -> @negate()

  '.negative?': -> Boolean.new @isNegative()

  '.round': (context, places = ZERO) ->
    m = Decimal(10).pow(places._value)
    return @copy m.times(@_value).round().div(m)

  '.ceil': ->  @copy @_value.ceil()

  '.floor': -> @copy @_value.floor()

  '.abs': -> @copy @_value.abs()

  '.pow': (context, exp = TWO) ->
    # TODO do not default exp to 2; instead, require this argument
    @copy @_value.pow(exp._value)

  '.sq': -> @['.pow'] TWO

  '.root': (context, deg = TWO) ->
    if @_value.isNegative()
      throw new ValueError """
      Cannot make #{deg._value}th root of #{@repr()}: Base cannot be negative
      """
    @copy @_value.pow(Decimal(1).div(deg._value))

  '.sqrt': -> @['.root'] TWO

  '.mod': (context, other) ->
    if other._value.isZero()
      throw new ValueError 'Cannot divide by 0'
    @copy @_value.mod(other._value)

  '.sin': -> @copy @_value.sin()

  '.cos': -> @copy @_value.cos()

  '.tan': -> @copy @_value.tan()

  '.asin': -> @copy @_value.asin()

  '.acos': -> @copy @_value.acos()

  '.atan': -> @copy @_value.atan()

  '.prime?': -> Boolean.new @isPrime()

  '.convert': (context, unit) ->
    if unit.isNull()
      unit = null
    else
      unit = unit.toString()

    @convert unit

Object::toNumber = ->
  throw new Error "Cannot convert #{@repr()} to number"

Boolean::toNumber = ->
  new Number (if @value then 1 else 0)

Object::['.number'] = -> @toNumber()

###
TODO: This should go to the `css-units` module.
###
Number.define frm, to for frm, to of {
  '1cm':     '10mm'
  '40q':     '1cm'
  '1in':     '25.4mm'
  '96px':    '1in'
  '72pt':    '1in'
  '1pc':     '12pt'
  '180deg':  "#{Math.PI}rad"
  '1turn':   '360deg'
  '400grad': '1turn'
  '1s':      '1000ms'
  '1kHz':    '1000Hz'
  '1dppx':   '96dpi'
  '1dpcm':   '2.54dpi'
}

module.exports = Number
