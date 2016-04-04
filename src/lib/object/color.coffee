Object  = require '../object'
Null    = require './null'
Boolean = require './boolean'

class Color extends Object

  SPACES =
    rgb:
      red:        [0, 255]
      green:      [0, 255]
      blue:       [0, 255]
    hsl:
      hue:        [0, 360, 'deg']
      saturation: [0, 100, '%']
      lightness:  [0, 100, '%']
    hsv:
      hue:        [0, 360, 'deg']
      saturation: [0, 100, '%']
      value:      [0, 100, '%']
    hwb:
      hue:        [0, 360, 'deg']
      whiteness:  [0, 100, '%']
      blackness:  [0, 100, '%']

  RE_HEX_COLOR  = /#([\da-f])+/i
  RE_FUNC_COLOR = ///
                  ([a-z_-][a-z\d_-]*)\s*
                  \(\s*
                    (\d[a-z%]*
                    (?:\s*,\s*\d[a-z%]*)*)
                  \s*\)///i

  @rgb2hsl = (rgb) ->

  @rgb2hwb = (rgb) ->

  @rgb2cmyk = (rgb) ->

  @cmyk2rgb = (cmyk) ->

  @hsl2rgb = (hsl) ->

  @hwb2rgb = (hwb) ->

  _parseHexString: (str) ->
    if m = str.match RE_HEX_COLOR
      hex = m[1]
      l = hex.length

      switch l
        when 1
          red = green = blue = 17 * parseInt hex, 16
        when 2
          red = green = blue = parseInt hex, 16
        when 3, 4
          red   = 17 * parseInt hex[0], 16
          green = 17 * parseInt hex[1], 16
          blue  = 17 * parseInt hex[2], 16
          if l > 3
            @alpha = 17 * parseInt hex[3], 16
        when 6, 8
          red   = parseInt hex[0..1], 16
          green = parseInt hex[2..3], 16
          blue  = parseInt hex[4..5], 16
          if l > 6
            @alpha = parseInt hex[6..7], 16
        else
          throw new Error "Bad hex color: #{color}"

      @rgb =
        red: red
        green: green
        blue: blue

      return true

  _parseFuncString: (str) ->
    if m = str.match RE_FUNC_COLOR
      space = m[1].toLowerCase()
      args = m[2].toLowerCase().split /(\s*,\s*)+/

      # TODO UNITS!
      if space of SPACES
        channels = {}

        # TODO I'm trusting the property order of SPACES[space] members
        # **DO NOT** http://stackoverflow.com/a/5525820
        for channel of SPACES[space]
          channels[channel] = args.shift()

        @[space] = channels

        if args.length > 1
          @alpha = args.shift()

        if args.length
          throw new Error "Too many values passed to `#{space()}`"

        return true

      else
        throw new Error "Bad color space: #{space}"

  constructor: (color = '#0000') ->
    @spaces = {}
    @alpha = 1

    @_parseHexString(color) or
    @_parseFuncString(color) or
    throw new Error "Bad color string: #{color}"

  getChannel: (channel, space) ->
    @spaces[space][channel]

  for space of SPACES
    @property space,
      get: ->
        unless @spaces[space]
          for other of @spaces
            convertor = @constructor["#{other}2#{space}".toUpperCase()]

            if convertor
              @spaces[space] = convertor.call @, other

        return @spaces[space]

      set: (values) ->
        for other of @spaces
          if other is space
            @spaces[other] = values
            @space = space
          else
            @spaces[other] = null

    for channel of SPACES[space]
      @property channel,
        get: -> @getChannel channel, space
        set: (value) -> @setChannel channel, value, space

  setChannel: (channel, value, space) ->
    unless channel of SPACE[space]
      throw new Error "Unknown channel: #{channel}"

    values = @spaces[space]

    # Do not invalidate cached conversions
    if values[channel] isnt value
      values[channel] = value
      @spaces[space] = values

  adjustChannel: (channel, amount, unit, space) ->
    if space of SPACES
      if channel of SPACES[space]
        if unit is '%'
          @[space][channel] += @[space][channel] * amount
        else
          if unit and unit isnt SPACES[space][2]
            throw new Error ":("
          value = @[space][channel] + amount
      else
        throw new Error "Unknown `#{space}` channel: `#{channel}`"
    else
      throw new Error "Unknown space: #{space}"

  # TODO Should I first try with current color space if it's not
  # rgb?
  @property 'luminance',
    get: -> .2126 * @red + .7152 * @green + .0722 * @blue

  blend: (backdrop, mode) -> @constructor.blend @, backdrop, mode

  isEqual: (other) ->
    for channel of @spaces[@space]
      if @spaces[@space][channel] isnt other.getChannel channel, space
        return no

    return yes

  isEmpty: -> @alpha is 0

  clone: -> # TODO

  '.transparent?': -> Boolean.new @isEmpty()

  '.transparent': ->
    that = @clone()
    that.alpha = 0
    that

  '.opaque?': -> Boolean.new @alpha is 1

  '.opaque': ->
    that = @clone()
    that.alpha = 1
    that

  '.saturate': (amount) -> # TODO

  '.desaturate': (amount = Number.ONE_HUNDRED_PERCENT) -> # TODO

  '.light?': -> Boolean.new @lightness >= .5

  '.dark?': -> Boolean.new @lightness < .5

  '.grey': -> @desaturate()

  @::['.gray'] = @::['.grey']

  '.grey?': -> # TODO

  @::['.gray?'] = @::['.grey?']

  '.spin': (amount) -> # TODO

  @::['.rotate'] = @::['.spin']

  # https://www.w3.org/TR/WCAG20/#relativeluminancedef
  '.luminance': -> new Number 100 * @luminance, '%'

  '.luminance?': -> Boolean.new @luminance > 0

  # TODO
  # http://dev.w3.org/csswg/css-color/#tint-shade-adjusters
  '.tint': (amount) ->

  '.shade': (amount)  ->

  '.contrast': (another) ->

  '.blend': (backdrop, mode = null) ->
    if mode isnt null
      if mode instanceof String
        mode = mode.value
      else
        throw new TypeError (
          "Bad `mode` argument for [#{@reprType().blend}"
        )

    unless backdrop instanceof Color
      throw new TypeError (
        "Bad `mode` argument for [#{@reprType().blend}"
      )

    @blend backdrop, mode

  # Individual channel accessors
  for space of SPACES
    for channel of SPACES[space]
      @::[".#{channel}"] = (space = Null.null) ->
      @::[".#{channel}?"] = (space = Null.null) ->
      # Looks like I need extra params passed on an assignment,
      # besides the "value" itself.
      #     #fff.saturation(hsl) = 50%
      # Is that *very* wrong?
      @::[".#{channel}="] = (value, space = Null.null) ->

module.exports = Color
