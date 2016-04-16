Object  = require '../object'
Null    = require './null'
Boolean = require './boolean'
Number  = require './number'
String  = require './string'

class Color extends Object

  RED         = name: 'red', max: 255, unit: null
  GREEN       = name: 'green', max: 255, unit: null
  BLUE        = name: 'blue', max: 255, unit: null
  HUE         = name: 'hue', max: 360, unit: 'deg'
  SATURATION  = name: 'saturation', max: 100, unit: '%'
  LIGHTNESS   = name: 'lightness', max: 100, unit: '%'
  WHITENESS   = name: 'whiteness', max: 100, unit: '%'
  BLACKNESS   = name: 'blackness', max: 100, unit: '%'
  CYAN        = name: 'cyan', max: 100, unit: '%'
  MAGENTA     = name: 'magenta', max: 100, unit: '%'
  YELLOW      = name: 'yellow', max: 100, unit: '%'
  BLACK       = name: 'black', max: 100, unit: '%'

  SPACES =
    rgb:  [ RED, GREEN, BLUE ]
    hsl:  [ HUE, SATURATION, LIGHTNESS ]
    hwb:  [ HUE, WHITENESS, BLACKNESS ]
    cmyk: [ CYAN, MAGENTA, YELLOW, BLACK ]

  RE_HEX_COLOR  = /#([\da-f]+)/i
  RE_FUNC_COLOR = /([a-z_-][a-z\d_-]*)\s*\((.*)\)/i

  {round, max, min, abs, sqrt} = Math

  @rgb2hsl = (rgb) ->
    r = rgb[0] / 255
    g = rgb[1] / 255
    b = rgb[2] / 255

    # http://git.io/ot_KMg
    # http://stackoverflow.com/questions/2353211/
    M = max r, g, b
    m = min r, g, b
    l = (M + m) / 2

    if m is M
      h = s = 0 # achromatic
    else
      d = M - m
      s = if l > .5 then d / (2 - M - m) else d / (M + m)
      h = (switch M
        when r
          (g - b) / d + (if g < b then 6 else 0)
        when g
          (b - r) / d + 2
        when b
          (r - g) / d + 4
      ) / 6

    [h * 360, s * 100, l * 100]

  @rgb2hwb = (rgb) ->
    # https://git.io/vVWUt
    h = (@rgb2hsl rgb)[0]
    w = min rgb...
    b = 255 - (max rgb...)

    [100 * h / 255, 100 * w / 255, 100 * b / 255]

  ###

  To naively convert from RGBA to CMYK:

  black = 1 - max(red, green, blue)
  cyan = (1 - red - black) / (1 - black), or 0 if black is 1
  magenta = (1 - green - black) / (1 - black), or 0 if black is 1
  yellow = (1 - blue - black) / (1 - black), or 0 if black is 1
  alpha is the same as the input color

  https://drafts.csswg.org/css-color/#cmyk-rgb
  ###
  @rgb2cmyk = (rgb) ->
    r = rgb[0] / 255
    g = rgb[1] / 255
    b = rgb[2] / 255

    k = 1 - max r, g, b

    if k is 1
      c = m = y = 0
    else
      w = 1 - k
      c = (1 - r - k) / w
      m = (1 - g - k) / w
      y = (1 - b - k) / w

    [c * 100, m * 100, y * 100, k * 100]

  ###
  ###
  @hsl2rgb = (hsl) ->
    s = hsl[1] / 100
    l = hsl[2] / 100

    if s is 0
      r = g = b = l # achromatic
    else
      h = hsl[0] / 360
      q = if l < .5 then l * (1 + s) else l + s - l * s
      p = 2 * l - q

      h2rgb = (t) ->
        if t < 0
          t++
        else if t > 1
          t--

        if t < 1 / 6
          p + (q - p) * 6 * t
        else if t < 1 / 2
          q
        else if t < 2 / 3
          p + (q - p) * (2 / 3 - t) * 6
        else
          p

      r = h2rgb (h + 1 / 3)
      g = h2rgb h
      b = h2rgb (h - 1 / 3)

    [r * 255, g * 255, b * 255]

  ###
  To naively convert from CMYK to RGBA:

  red = 1 - min(1, cyan * (1 - black) + black)
  green = 1 - min(1, magenta * (1 - black) + black)
  blue = 1 - min(1, yellow * (1 - black) + black)
  alpha is same as for input color.

  https://drafts.csswg.org/css-color/#cmyk-rgb
  ###
  @cmyk2rgb = (cmyk) ->
    c = cmyk[0] / 100
    m = cmyk[1] / 100
    y = cmyk[2] / 100
    k = cmyk[3] / 100

    w = 1 - k
    r = 1 - min(1, (c * w + k))
    g = 1 - min(1, (m * w + k))
    b = 1 - min(1, (y * w + k))

    [r * 255, g * 255, b * 255]

  # https://drafts.csswg.org/css-color/#hwb-to-rgb
  @hwb2rgb = (hwb) ->
    [h, w, b] = hwb

    rgb = @hsl2rgb [h, 100, 50]

    for i in [0..2]
      rgb[i] *= (1 - w / 100 - b / 100)
      rgb[i] += 255 * w / 100

    rgb

  # "source-over" compositing ????
  #
  # https://www.w3.org/TR/compositing-1/#generalformula   ??????
  # https://www.w3.org/TR/2003/REC-SVG11-20030114/masking.html#SimpleAlphaBlending
  # https://en.wikipedia.org/wiki/Alpha_compositing
  @composite: (source, backdrop) ->
    salpha = source.alpha
    balpha = backdrop.alpha
    srgb = source.rgb
    brgb = backdrop.rgb

    compositeChannel = (source, backdrop) ->
      (salpha * source + balpha * backdrop * (1 - salpha)) /
      (salpha + balpha * (1 - salpha))

    composited = (
      compositeChannel srgb[i] / 255, brgb[i] / 255 for i of srgb
    ).map (channel) -> channel * 255

    that = source.clone()
    that.rgb = composited
    that.alpha = salpha + balpha * (1 - salpha)
    that

  @blendSeparate: (source, backdrop, func) ->
    srgb = source.rgb
    brgb = backdrop.rgb
    blent = (
      func.call @, srgb[i] / 255, brgb[i]  / 255 for i of srgb
    )
    blent = blent.map (channel) -> channel * 255
    that = source.clone()
    that.rgb = blent
    that

  ###
  The no-blending mode. This simply selects the source color.
  ###
  @blendChannelNormal: (source, backdrop) ->
    source

  @blendNormal: (source, backdrop) ->
    @blendSeparate source, backdrop, @blendChannelNormal

  ###
  The source color is multiplied by the backdrop.

  The result color is always at least as dark as either the source or backdrop
  color. Multiplying any color with black produces black. Multiplying any color
  with white leaves the color unchanged.
  ###
  @blendChannelMultiply: (source, backdrop) ->
    source * backdrop

  @blendMultiply: (source, backdrop) ->
    @blendSeparate source, backdrop, @blendChannelMultiply


  ###
  Multiplies the complements of the backdrop and source color values, then
  complements the result.

  The result color is always at least as light as either of the two constituent
  colors. Screening any color with white produces white; screening with black
  leaves the original color unchanged. The effect is similar to projecting
  multiple photographic slides simultaneously onto a single screen.
  ###
  @blendChannelScreen: (source, backdrop) ->
    backdrop + source - backdrop * source

  @blendScreen: (source, backdrop) ->
    @blendSeparate source, backdrop, @blendChannelScreen

  ###
  Multiplies or screens the colors, depending on the backdrop color value.
  Source colors overlay the backdrop while preserving its highlights and
  shadows. The backdrop color is not replaced but is mixed with the source
  color to reflect the lightness or darkness of the backdrop.

  Overlay is the inverse of the `hard-light` blend mode.
  ###
  @blendChannelOverlay: (source, backdrop) ->
    if source < .5
      2 * source * backdrop
    else
      1 - 2 * (1 - source) * (1 - backdrop)

  @blendOverlay: (source, backdrop) ->
    @blendSeparate source, backdrop, @blendChannelOverlay

  ###
  Selects the darker of the backdrop and source colors.

  The backdrop is replaced with the source where the source is darker;
  otherwise, it is left unchanged.
  ###
  @blendChannelDarken: (source, backdrop) ->
    min source, backdrop

  @blendDarken: (source, backdrop) ->
    @blendSeparate source, backdrop, @blendChannelDarken

  ###
  Selects the lighter of the backdrop and source colors.

  The backdrop is replaced with the source where the source is lighter;
  otherwise, it is left unchanged.
  ###
  @blendChannelLighten: (source, backdrop) ->
    max backdrop, source

  @blendLighten: (source, backdrop) ->
    @blendSeparate source, backdrop, @blendChannelLighten

  ###
  Brightens the backdrop color to reflect the source color. Blending with black
  produces no changes.
  ###
  @blendChannelColorDodge: (source, backdrop) ->
    if backdrop is 0
      0
    else if source is 1
      1
    else
      min 1, backdrop / (1 - source)

  @blendColorDodge: (source, backdrop) ->
    @blendSeparate source, backdrop, @blendChannelColorDodge

  ###
  Darkens the backdrop color to reflect the source color. Blending with white
  produces no changes.
  ###
  @blendChannelColorBurn: (source, backdrop) ->
    if backdrop is 1
      1
    else if source is 0
      0
    else
      min 1, (1 - backdrop) / source

  @blendColorBurn: (source, backdrop) ->
    @blendSeparate source, backdrop, @blendChannelColorBurn

  ###
  Multiplies or screens the colors, depending on the source color value. The
  effect is similar to shining a harsh spotlight on the backdrop.
  ###
  @blendChannelHardLight: (source, backdrop) ->
    @blendChannelOverlay backdrop, source

  @blendHardLight: (source, backdrop) ->
    @blendSeparate source, backdrop, @blendChannelHardLight

  ###
  Darkens or lightens the colors, depending on the source color value. The
  effect is similar to shining a diffused spotlight on the backdrop

  https://en.wikipedia.org/wiki/Blend_modes#Soft_Light
  ###
  @blendChannelSoftLight: (source, backdrop) ->
    if backdrop <= .5
      source - (1 - 2 * backdrop) * source * (1 - source)
    else
      if source <= .25
        d = ((16 * source - 12) * source + 4) * source
      else
        d = sqrt source

      source + (2 * backdrop - 1) * (d - source)

  @blendSoftLight: (source, backdrop) ->
    @blendSeparate source, backdrop, @blendChannelSoftLight

  ###
  Subtracts the darker of the two constituent colors from the lighter color.

  Painting with white inverts the backdrop color; painting with black produces
  no change.
  ###
  @blendChannelDifference: (source, backdrop) ->
    abs backdrop - source

  @blendDifference: (source, backdrop) ->
    @blendSeparate source, backdrop, @blendChannelDifference

  ###
  Produces an effect similar to that of the `difference` mode but lower in
  contrast. Painting with white inverts the backdrop color; painting with black
  produces no change.
  ###
  @blendChannelExclusion: (source, backdrop) ->
    source + backdrop - 2 * source * backdrop

  @blendExclusion: (source, backdrop) ->
    @blendSeparate source, backdrop, @blendChannelExclusion

  ###
  Creates a color with the hue of the source color and the saturation and
  luminosity of the backdrop color.
  ###
  @blendHue: (source, backdrop) ->
    source.toHSL source.hue, backdrop.saturation, backdrop.lightness

  ###
  Creates a color with the saturation of the source color and the hue and
  luminosity of the backdrop color.

  Painting with this mode in an area of the backdrop that is a pure gray (no
  saturation) produces no change.
  ###
  @blendSaturation: (source, backdrop) ->
    source.toHSL backdrop.hue, source.saturation, backdrop.lightness

  ###
  Creates a color with the hue and saturation of the source color and the
  luminosity of the backdrop color.

  This preserves the gray levels of the backdrop and is useful for coloring
  monochrome images or tinting color images.
  ###
  @blendColor: (source, backdrop) ->
    source.toHSL source.hue, source.saturation, backdrop.lightness

  ###
  Creates a color with the luminosity of the source color and the hue and
  saturation of the backdrop color. This produces an inverse effect to that of
  the `color` mode.
  ###
  @blendLuminosity: (source, backdrop) ->
    source.toHSL backdrop.hue, backdrop.saturation, source.lightness

  @blend: (source, backdrop, mode = 'normal') ->
    method = "blend-#{mode}".replace /(-\w)/g, (m) -> m[1].toUpperCase()

    if method of @
      blent = @[method] source, backdrop
      @composite blent, backdrop
    else
      throw new Error "Bad mode for Color.blend: #{mode}"

  toHSL: (hue, saturation, lightness) ->
    that = @clone()
    that.hsl = [hue, saturation, lightness]
    that

  _parseHexString: (str) ->
    if m = str.match RE_HEX_COLOR
      str = m[1]
      l = str.length

      switch l
        when 1
          red = green = blue = 17 * parseInt str, 16
        when 2
          red = green = blue = parseInt str, 16
        when 3, 4
          red   = 17 * parseInt str[0], 16
          green = 17 * parseInt str[1], 16
          blue  = 17 * parseInt str[2], 16
          if l > 3
            @alpha = (17 * parseInt str[3], 16) / 255
        when 6, 8
          red   = parseInt str[0..1], 16
          green = parseInt str[2..3], 16
          blue  = parseInt str[4..5], 16
          if l > 6
            @alpha = (parseInt str[6..7], 16) / 255
        else
          throw new Error "Bad hex color: #{str}"

      @space = 'rgb'

      return @spaces['rgb'] = [ red, green, blue ]

  _parseFuncString: (str) ->
    if m = str.match RE_FUNC_COLOR
      space = m[1].toLowerCase()

      if space[-1..] is 'a'
        space = space[...-1]

      args = m[2].toLowerCase().split /(?:\s*,\s*)+/

      # TODO UNITS!
      if space of SPACES
        channels = []

        for channel in SPACES[space]
          channels.push parseFloat args.shift()

        if args.length
          @alpha = parseFloat args.shift()

        if args.length
          throw new Error "Too many values passed to `#{space}()`"

        @space = space
        return @spaces[space] = channels

      else
        throw new Error "Bad color space: #{space}"

  constructor: (color = '#0000') ->
    @spaces = {}
    @alpha = 1

    @_parseHexString(color) or
    @_parseFuncString(color) or
    throw new Error "Bad color string: #{color}"

  do =>
    make_space_accessors = (space) =>
      @property space,
        get: ->
          unless @spaces[space]
            convertor = null

            unless @space is space
              if convertor = @constructor["#{@space}2#{space}"]
                other = @space

            if not convertor
              for other of @spaces
                unless other in [space, @space]
                  convertor = @constructor["#{other}2#{space}"]
                  break if convertor

            if not convertor
              throw new Error "No convertor to #{space} :("

            @spaces[space] = convertor.call @constructor, @spaces[other]

          return @spaces[space]

        set: (values) ->
          @space = space
          @spaces = {}
          @spaces[space] = values

    make_channel_accessors = (space, index, name) =>
      unless name of @::
        @property name,
          get: -> @[space][index]
          set: (value) ->
            space = @[space]
            space[index] = value
            @[space] = space

    for space of SPACES
      make_space_accessors space

      for channel, index in SPACES[space]
        make_channel_accessors space, index, channel.name

  getChannel: (space, channel) -> @[space][channel]

  setChannel: (space, channel, value) ->
    channels = @[space]
    channels[channel] = @clampChannel space, channel, value
    @[space] = channels

  clampChannel: (space, channel, value) ->
    if SPACES[space][channel].unit is 'deg'
      value %= SPACES[space][channel].max
      if value < 0
        value += SPACES[space][channel].max
    else
      value = min value, SPACES[space][channel].max
      value = max value, 0

    return value

  adjustChannel: (space, channel, amount, unit) ->
    if unit is '%'
      amount = SPACES[space][channel].max * amount / 100
    else if unit and unit isnt SPACES[space][channel].unit
      throw new Error "Bad value for #{space} #{channel}: #{amount}#{unit}"

    @setChannel space, channel, amount + @getChannel space, channel

  # TODO Should I first try with current color space if it's not
  # rgb?
  @property 'luminance',
    get: -> .2126 * @red / 255 + .7152 * @green / 255 + .0722 * @blue / 255

  composite: (backdrop) -> @constructor.composite @, backdrop

  blend: (backdrop, mode) -> @constructor.blend @, backdrop, mode

  isEqual: (other) ->
    if other instanceof Color
      for channel of @spaces[@space]
        if @spaces[@space][channel] isnt other[@space][channel]
          return no

      return @alpha is other.alpha

    return no

  isEmpty: -> @alpha is 0

  toRGBAString: ->
    comps = @['rgb'].map (c) -> round c

    if @alpha < 1
      comps.push (round @alpha * 100) / 100

    return "rgba(" + (comps.join ', ') + ')'

  toHexString: ->
    comps = [].concat @['rgb']

    if @alpha < 1
      comps.push @alpha * 255

    hex = '#'

    for c in comps
      c = (round c).toString 16
      if c.length < 2
        hex += '0'

      hex += c

    return hex

  toString: ->
    if @alpha < 1
      @toRGBAString()
    else
      @toHexString()

  clone: (color = null, etc...) ->
    color = color or @toString()
    super color, etc...

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

  '.saturate': (amount) ->
    if amount instanceof Number
      that = @clone()
      that.adjustChannel 'hsl', 1, amount.value, amount.unit
      that
    else
      throw new TypeError "Bad argument for #{@reprType()}.saturate"

  '.desaturate': (amount = Number.ONE_HUNDRED_PERCENT) ->
    if amount instanceof Number
      that = @clone()
      that.adjustChannel 'hsl', 1, -1 * amount.value, amount.unit
      return that
    else
      throw new TypeError "Bad argument for #{@reprType()}.saturate"

  '.whiten': (amount = Number.FIFTY_PERCENT) ->
    if amount instanceof Number
      that = @clone()
      that.adjustChannel 'hwb', 1, amount.value, amount.unit
      that
    else
      throw new TypeError "Bad argument for #{@reprType()}.tint"

  '.blacken': (amount = Number.FIFTY_PERCENT) ->
    if amount instanceof Number
      that = @clone()
      that.adjustChannel 'hwb', 2, amount.value, amount.unit
      that
    else
      throw new TypeError "Bad argument for #{@reprType()}.shade"

  '.light?': -> Boolean.new @lightness >= 50

  '.dark?': -> Boolean.new @lightness < 50

  '.grey': -> @desaturate()

  @::['.gray'] = @::['.grey']

  '.grey?': ->
    Boolean.new (@red is @blue and @blue is @green)

  @::['.gray?'] = @::['.grey?']

  '.spin': (amount) ->
    if amount instanceof Number
      amount = amount.convert('deg')
      that = @clone()
      that.adjustChannel 'hsl', 0, amount.value, amount.unit
      that
    else
      throw new TypeError "Bad argument for #{@reprType()}.saturate"

  @::['.rotate'] = @::['.spin']

  # https://www.w3.org/TR/WCAG20/#relativeluminancedef
  '.luminance': -> new Number 100 * @luminance, '%'

  '.luminance?': -> Boolean.new @luminance > 0

  '.invert': ->
    that = @clone()
    rgb = (255 - channel for channel in that.rgb)
    that.rgb = rgb
    that

  # http://dev.w3.org/csswg/css-color/#tint-shade-adjusters
  '.tint': (amount = Number.FIFTY_PERCENT) ->
    white = new Color '#fff'
    white.alpha = amount.value / 100
    white.composite @

  '.shade': (amount = Number.FIFTY_PERCENT) ->
    black = new Color '#000'
    black.alpha = amount.value / 100
    black.composite @

  '.contrast': (another) ->

  '.blend': (backdrop, mode = null) ->
    if mode isnt null
      if mode instanceof String
        mode = mode.value
      else
        throw new TypeError (
          "Bad `mode` argument for [#{@reprType()}.blend]"
        )

    unless backdrop instanceof Color
      throw new TypeError (
        "Bad `mode` argument for [#{@reprType()}.blend]"
      )

    @blend backdrop, mode

  # Individual channel accessors
  '.alpha': ->
    new Number @alpha

  '.alpha=': (value) ->
    if value instanceof Number
      if value.unit is '%'
        value = value.value / 100
      else if value.isPure()
        value = value.value
      else
        throw new Error "Bad alpha value: #{value}"

      value = min 1, (max value, 0)
      @alpha = value
    else
      throw new Error "Bad alpha value: #{value}"

  '.alpha?': ->
    Boolean.new @alpha > 0

  do =>
    make_accessors = (space, index, channel) =>
      name = channel.name

      @::[".#{name}"] ?= ->
        new Number @[space][index], channel.unit

      @::[".#{name}?"] ?= ->
        Boolean.new @[space][index] > 0

      @::[".#{name}="] ?= (value) ->
        if value instanceof Number
          if value.unit is '%'
            value = channel.max * value.value / 100
          else
            if channel.unit and not value.isPure()
              value = value.convert channel.unit

            value = @clampChannel space, index, value.value

          channels = @[space]
          channels[index] = value
          @[space] = channels

        else
          throw new Error "Bad #{name} channel value: #{value.repr()}"

    for space of SPACES
      for channel, index in SPACES[space]
        make_accessors space, index, channel


module.exports = Color
