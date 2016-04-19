Object     = require '../object'
Null       = require './null'
Boolean    = require './boolean'
Number     = require './number'
String     = require './string'
ValueError = require '../error/value'

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

  BLEND_MODES = [
    'normal'
    'multiply'
    'screen'
    'overlay'
    'hard-light'
    'soft-light'
    'darken'
    'lighten'
    'difference'
    'exclusion'
    'hue'
    'saturation'
    'color'
    'luminosity'
    'color-dodge'
    'color-burn'
  ]

  RE_HEX_COLOR  = /#([\da-f]+)/i
  RE_FUNC_COLOR = /([a-z_-][a-z\d_-]*)\s*\((.*)\)/i

  {round, max, min, abs, sqrt, pow} = Math

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
      q = if l <= .5 then l * (1 + s) else l + s - l * s
      p = 2 * l - q

      h2rgb = (t) ->
        if t < 0
          t++
        else if t > 1
          t--

        if t * 6 < 1
          p + (q - p) * 6 * t
        else if t * 2 < 1
          q
        else if t * 3 < 2
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
    @blendChannelHardLight backdrop, source

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

  if(Cb == 0)
    B(Cb, Cs) = 0
  else if(Cs == 1)
    B(Cb, Cs) = 1
  else
    B(Cb, Cs) = min(1, Cb / (1 - Cs))
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

  if(Cb == 1)
    B(Cb, Cs) = 1
  else if(Cs == 0)
    B(Cb, Cs) = 0
  else
    B(Cb, Cs) = 1 - min(1, (1 - Cb) / Cs)
  ###
  @blendChannelColorBurn: (source, backdrop) ->
    if backdrop is 1
      1
    else if source is 0
      0
    else
      1 - min 1, (1 - backdrop) / source

  @blendColorBurn: (source, backdrop) ->
    @blendSeparate source, backdrop, @blendChannelColorBurn

  ###
  Multiplies or screens the colors, depending on the source color value. The
  effect is similar to shining a harsh spotlight on the backdrop.
  ###
  @blendChannelHardLight: (source, backdrop) ->
    if source <= .5
      @blendChannelMultiply backdrop, 2 * source
    else
      @blendChannelScreen backdrop, 2 * source - 1

  @blendHardLight: (source, backdrop) ->
    @blendSeparate source, backdrop, @blendChannelHardLight

  ###
  Darkens or lightens the colors, depending on the source color value. The
  effect is similar to shining a diffused spotlight on the backdrop

  https://en.wikipedia.org/wiki/Blend_modes#Soft_Light

  ###
  @blendChannelSoftLight: (source, backdrop) ->
    if source <= .5
      backdrop - (1 - 2 * source) * backdrop * (1 - backdrop)
    else
      if backdrop <= .25
        d = ((16 * backdrop - 12) * backdrop + 4) * backdrop
      else
        d = sqrt backdrop
      backdrop + (2 * source - 1) * (d - backdrop)

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


  do =>
    getLum = (red, green, blue) ->
      .3 * red + .59 * green + .11 * blue

    clipColor = (red, green, blue) ->
      l = getLum red, green, blue
      n = min red, green, blue
      x = max red, green, blue

      if n < 0
        red   = l + (((red - l) * l) / (l - n))
        green = l + (((green - l) * l) / (l - n))
        blue  = l + (((blue - l) * l) / (l - n))

      if x > 1
        red = l + (((red - l) * (1 - l)) / (x - l))
        green = l + (((green - l) * (1 - l)) / (x - l))
        blue = l + (((blue - l) * (1 - l)) / (x - l))

      [red, green, blue]

    setLum = (red, green, blue, l) ->
      d = l - getLum red, green, blue
      red += d
      green += d
      blue += d

      clipColor red, green, blue

    getSat =(red, green, blue) ->
      (max red, green, blue) - (min red, green, blue)

    setSat = (red, green, blue, sat) ->
      rgb = [red, green, blue]

      mx = max red, green, blue
      mn = min red, green, blue

      mn =
        if mn is red
          0
        else if mn is green
          1
        else
          2
      mx =
        if mn is red
          0
        else if mn is green
          1
        else
          2

      md =
        if 0 is min mn, mx
          if 1 is max mn, mx
            2
          else
            1
        else
          0

      if rgb[mx] > rgb[mn]
        rgb[md] = ((rgb[md] - rgb[mn]) * sat) / (rgb[mx] - rgb[mn])
        rgb[mx] = sat
      else
        rgb[md] = rgb[mx] = 0

      rgb[mn] = 0

      return rgb

    ###
    Creates a color with the hue of the source color and the saturation and
    luminosity of the backdrop color.

    B(Cb, Cs) = SetLum(SetSat(Cs, Sat(Cb)), Lum(Cb))
    ###
    @blendHue = (source, backdrop) ->
      source_rgb = source.rgb.map (ch) -> ch / 255
      backdrop_rgb = backdrop.rgb.map (ch) -> ch / 255

      sat = getSat backdrop_rgb...
      lum = getLum backdrop_rgb...

      blent_rgb = setLum(setSat(source_rgb..., sat)..., lum)

      blent_rgb = blent_rgb.map (ch) -> ch * 255
      blent = source.clone()
      blent.rgb = blent_rgb
      blent.composite backdrop

    ###
    Creates a color with the luminosity of the source color and the hue and
    saturation of the backdrop color. This produces an inverse effect to that of
    the `color` mode.

    B(Cb, Cs) = SetLum(Cb, Lum(Cs))
    ###
    @blendLuminosity = (source, backdrop) ->
      source_rgb = source.rgb.map (ch) -> ch / 255
      backdrop_rgb = backdrop.rgb.map (ch) -> ch / 255
      source_lum = getLum source_rgb...
      blent_rgb = setLum backdrop_rgb..., source_lum
      blent_rgb = blent_rgb.map (ch) -> ch * 255
      blent = backdrop.clone()
      blent.rgb = blent_rgb
      blent.composite backdrop

    ###
    Creates a color with the hue and saturation of the source color and the
    luminosity of the backdrop color.

    This preserves the gray levels of the backdrop and is useful for coloring
    monochrome images or tinting color images.

    B(Cb, Cs) = SetLum(Cs, Lum(Cb))
    ###
    @blendColor = (source, backdrop) ->
      source_rgb = source.rgb.map (ch) -> ch / 255
      backdrop_rgb = backdrop.rgb.map (ch) -> ch / 255
      lum = getLum backdrop_rgb...
      blent_rgb = setLum source_rgb..., lum
      blent_rgb = blent_rgb.map (ch) -> ch * 255
      blent = source.clone()
      blent.rgb = blent_rgb
      blent.composite backdrop

  ###
  Creates a color with the saturation of the source color and the hue and
  luminosity of the backdrop color.

  Painting with this mode in an area of the backdrop that is a pure gray (no
  saturation) produces no change.
  ###
  @blendSaturation: (source, backdrop) ->
    source.toHSL backdrop.hue, source.saturation, backdrop.lightness

  @blend: (source, backdrop, mode = 'normal') ->
    if mode in BLEND_MODES
      method = "blend-#{mode}".replace /(-\w)/g, (m) -> m[1].toUpperCase()
      blent = @[method] source, backdrop
      @composite blent, backdrop
    else
      throw new ValueError "Bad mode for Color.blend: #{mode}"

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

    return @

  # https://drafts.csswg.org/css-color-4/#luminance
  @property 'luminance',
    get: ->
      [r, g, b] = [@red, @green, @blue].map (channel, i) ->
        channel /= 255
        if channel <= .03928
          channel / 12.92
        else
          pow (channel + .055) / 1.055, 2.4

      return .2126 * r + .7152 * g + .0722 * b

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
      @clone().adjustChannel 'hsl', 1, amount.value, amount.unit
    else
      throw new TypeError "Bad argument for #{@reprType()}.saturate"

  '.desaturate': (amount = Number.ONE_HUNDRED_PERCENT) ->
    if amount instanceof Number
      @clone().adjustChannel 'hsl', 1, -1 * amount.value, amount.unit
    else
      throw new TypeError "Bad argument for #{@reprType()}.saturate"

  '.whiten': (amount = Number.FIFTY_PERCENT) ->
    if amount instanceof Number
      @clone().adjustChannel 'hwb', 1, amount.value, amount.unit
    else
      throw new TypeError "Bad argument for #{@reprType()}.whiten"

  '.blacken': (amount = Number.FIFTY_PERCENT) ->
    if amount instanceof Number
      @clone().adjustChannel 'hwb', 2, amount.value, amount.unit
    else
      throw new TypeError "Bad argument for #{@reprType()}.blacken"

  '.darken': (amount = Number.TEN_PERCENT) ->
    if amount instanceof Number
      @clone().adjustChannel 'hsl', 2, -1 * amount.value, amount.unit
    else
      throw new TypeError "Bad argument for #{@reprType()}.darken"

  '.lighten': (amount = Number.TEN_PERCENT) ->
    if amount instanceof Number
      @clone().adjustChannel 'hsl', 2, amount.value, amount.unit
    else
      throw new TypeError "Bad argument for #{@reprType()}.lighten"

  # TODO: Use @luminance instead of @lightness?
  '.light?': -> Boolean.new @lightness >= 50
  '.dark?': -> Boolean.new @lightness < 50

  '.grey': -> @desaturate()

  @::['.gray'] = @::['.grey']

  '.grey?': ->
    Boolean.new (@red is @blue and @blue is @green)

  @::['.gray?'] = @::['.grey?']

  '.rotate': (amount) ->
    if amount instanceof Number
      amount = amount.convert('deg')
      @clone().adjustChannel 'hsl', 0, amount.value, amount.unit
    else
      throw new TypeError "Bad argument for #{@reprType()}.rotate"

  @::['.spin'] = @::['.rotate']

  '.opposite': ->
    @clone().adjustChannel 'hsl', 0, 180

  # https://www.w3.org/TR/WCAG20/#relativeluminancedef
  '.luminance': -> new Number 100 * @luminance, '%'

  '.luminance?': -> Boolean.new @luminance > 0

  '.invert': ->
    that = @clone()
    that.rgb = (255 - channel for channel in that.rgb)
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
  '.alpha': -> new Number @alpha

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

  do =>
    make_accessors = (space, index, channel) =>
      name = channel.name

      @::[".#{name}"] ?= ->
        new Number @[space][index], channel.unit

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
