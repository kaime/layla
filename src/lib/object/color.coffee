Object    = require '../object'
Boolean   = require './boolean'
Number    = require './number'
String    = require './string'

TypeError = require '../error/type'

class Color extends Object

  {max, min, abs, sqrt} = Math

  RGB_CHANNELS = ['red', 'green', 'blue']
  HSL_CHANNELS = ['hue', 'saturation', 'lightness']
  HSV_CHANNELS = ['hue', 'saturation', 'value']
  HWB_CHANNELS = ['hue', 'whiteness', 'blackness']
  CMYK_CHANNELS = ['cyan', 'magenta', 'yellow', 'black']

  CHANNELS = [].concat(
    RGB_CHANNELS,
    HSL_CHANNELS,
    HSV_CHANNELS,
    HWB_CHANNELS,
    CMYK_CHANNELS
    'alpha'
  )

  # Unique channel names
  CHANNELS =
    channel for channel, i in CHANNELS when i is CHANNELS.indexOf channel

  RGB2HSL = (r, g, b, a) ->
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

    [h, s, l, a]

  H2RGB = (p, q, t) ->
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

  ###
  ###
  HSL2RGB = (h, s, l, a) ->
    if s is 0
      r = g = b = l # achromatic
    else
      q = if l < .5 then l * (1 + s) else l + s - l * s
      p = 2 * l - q
      r = H2RGB p, q, (h + 1 / 3)
      g = H2RGB p, q, h
      b = H2RGB p, q, (h - 1 / 3)

    [r, g, b, a]

  ###

  To naively convert from RGBA to CMYK:

  black = 1 - max(red, green, blue)
  cyan = (1 - red - black) / (1 - black), or 0 if black is 1
  magenta = (1 - green - black) / (1 - black), or 0 if black is 1
  yellow = (1 - blue - black) / (1 - black), or 0 if black is 1
  alpha is the same as the input color

  https://drafts.csswg.org/css-color/#cmyk-rgb
  ###
  RGB2CMYK = (r, g, b, a) ->
    k = 1 - max(r, g, b)

    if k is 1
      c = m = y = 0
    else
      w = 1 - k
      c = (1 - r - k) / w
      m = (1 - g - k) / w
      y = (1 - b - k) / w

    [c, m, y, k, a]

  ###
  To naively convert from CMYK to RGBA:

  red = 1 - min(1, cyan * (1 - black) + black)
  green = 1 - min(1, magenta * (1 - black) + black)
  blue = 1 - min(1, yellow * (1 - black) + black)
  alpha is same as for input color.

  https://drafts.csswg.org/css-color/#cmyk-rgb
  ###
  CMYK2RGB = (c, m, y, k, a) ->
    w = 1 - k
    r = 1 - min(1, (c * w + k))
    g = 1 - min(1, (m * w + k))
    b = 1 - min(1, (y * w + k))

    [r, g, b, a]

  ###
  ###
  RGB2HWB = (r, g, b, a) ->
    # https://git.io/vVWUt
    h = (RGB2HSL r, g, b, a)[0]
    w = min r, g, b
    b = 1 - (max r, g, b)

    [h, w, b, a]

  HWB2RGB = (h, w, b, a) ->
    # http://dev.w3.org/csswg/css-color/#hwb-to-rgb
    rgba = HSL2RGB h, 1, .5, a
    rgba.map (c) -> c * (1 - w - b) + w

  HSL2HWB = (h, s, l, a) -> RGB2HWB (HSL2RGB h, s, l, a)...

  HWB2HSL = (h, w, b, a) -> RGB2HSL (HWB2RGB h, w, b, a)...

  @blendSeparate: (source, backdrop, func) ->
    blent = (
      func.call @, source[channel], backdrop[channel] for channel in RGB_CHANNELS
    )

    blent.push source.alpha * backdrop.alpha

    source.clone blent...

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
    if backdrop is 1
      1
    else if s is 0
      0
    else
      1 - min 1, (1 - backdrop) / source

      return 1 if b == 1
    return 0 if s == 0
    return 1 - min(1, (1 - b) / s)

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
      min 1, b / (1 - source)

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
      min 1, (1 - b) / s

  @blendColorBurn: (source, backdrop) ->
    @blendSeparate source, backdrop, @blendChannelColorBurn

  ###
  Multiplies or screens the colors, depending on the source color value. The
  effect is similar to shining a harsh spotlight on the backdrop.
  ###
  @blendChannelHardLight: (source, backdrop) ->
    if source <= .5
      @blendChannelMultiply 2 * source, backdrop
    else
      @blendChannelScreen 2 * source - 1, backdrop


  @blendHardLight: (source, backdrop) ->
    @blendSeparate source, backdrop, @blendChannelHardLight

  ###
  Darkens or lightens the colors, depending on the source color value. The
  effect is similar to shining a diffused spotlight on the backdrop
  ###
  @blendChannelSoftLight: (source, backdrop) ->
    if source <= .5
      backdrop - (1 - 2 * source) * backdrop * (1 - backdrop)
    else
      if backdrop < .25
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

  ###
  Creates a color with the hue of the source color and the saturation and
  luminosity of the backdrop color.
  ###
  @blendHue: (source, backdrop) ->
    @fromHSLA source.hue, backdrop.saturation, backdrop.lightness

  ###
  Creates a color with the saturation of the source color and the hue and
  luminosity of the backdrop color.

  Painting with this mode in an area of the backdrop that is a pure gray (no
  saturation) produces no change.
  ###
  @blendSaturation: (source, backdrop) ->
    @fromHSLA backdrop.hue, source.saturation, backdrop.lightness

  ###
  Creates a color with the hue and saturation of the source color and the
  luminosity of the backdrop color.

  This preserves the gray levels of the backdrop and is useful for coloring
  monochrome images or tinting color images.
  ###
  @blendColor: (source, backdrop) ->
    @fromHSLA source.hue, source.saturation, backdrop.lightness

  ###
  Creates a color with the luminosity of the source color and the hue and
  saturation of the backdrop color. This produces an inverse effect to that of
  the `color` mode.
  ###
  @blendLuminosity: (source, backdrop) ->
    @fromHSLA backdrop.source, backdrop.saturation, source.lightness

  @blend: (source, backdrop, mode = 'normal') ->
    method = "blend-#{mode}".replace /(-\w)/g, (m) -> m[1].toUpperCase()

    if method of @
      @[method] source, backdrop if method of @
    else
      throw new Error "Bad mode for Color.blend: #{mode}"

  @fromRGBA: (r, g, b, a = null) -> new @ r, g, b, a

  @fromHSLA: (h, s, l, a = null) -> new @ (HSL2RGB h, s, l, a)...

  @fromHSVA: (h, s, v, a = null) -> new @ (HSV2RGB h, s, v, a)...

  @fromHWBA: (h, w, b, a = null) -> new @ (HWB2RGB h, w, b, a)...

  @fromCMYKA: (h, s, v, a = null) -> new @ (CMYK2RGB c, m, y, k, a)...

  ###
  ###
  constructor: (@red = 0, @green = 0, @blue = 0, @alpha = 1) ->

  @property 'rgba',
    get: -> [@red, @green, @blue, @alpha]
    set: (rgba) ->
      @red   = rgba[0]
      @green = rgba[1]
      @blue  = rgba[2]
      @alpha = rgba[3]

  @property 'hsla',
    get: -> RGB2HSL @rgba...
    set: (hsla) -> @rgba = HSL2RGB hsla...

  @property 'hue',
    get: -> @hsla[0]
    set: (hue) ->
      hsla = @hsla
      hsla[0] = hue
      @hsla = hsla

  @property 'saturation',
    get: -> @hsla[1]
    set: (sat) ->
      hsla = @hsla
      hsla[1] = sat
      @hsla = hsla

  @property 'lightness',
    get: -> @hsla[2]
    set: (light) ->
      hsla = @hsla
      hsla[2] = light
      @hsla = hsla

  @property 'hsva',
    get: -> RGB2HSV @rgba...
    set: -> @rgba = HSV2RGB hsva...

  # Mmm... Is this the same as "brightness"?
  # http://www.acasystems.com/en/color-picker/faq-hsb-hsv-color.htm
  @property 'value',
    get: -> @hsva[2]
    set: (value) ->
      hsva = @hsva
      hsva[2] = value
      @hsva = hsva

  @property 'hwba',
    get: -> RGB2HWB @rgba...
    set: (hwba) -> @rgba = HWB2RGB hwba...

  @property 'blackness',
    get: -> @hwba[2]
    set: (value) ->
      hwba = @hwba
      hwba[2] = value
      @hwba = hwba

  @property 'whiteness',
    get: -> @hwba[1]
    set: (value) ->
      hwba = @hwba
      hwba[1] = value
      @hwba = hwba

  @property 'cmyka',
    get: -> RGB2CMYK @rgba...
    set: (cmyka) -> @rgba = CMYK2RGB cmyka...

  @property 'cyan',
    get: -> @cmyka[0]
    set: (value) ->
      cmyka = @cmyka
      cmyka[0] = value
      @cmyka = cmyka

  @property 'magenta',
    get: -> @cmyka[1]
    set: (value) ->
      cmyka = @cmyka
      cmyka[2] = value
      @cmyka = cmyka

  @property 'yellow',
    get: ->
      @cmyka[2]
    set: (value) ->
      cmyka = @cmyka
      cmyka[2] = value
      @cmyka = cmyka

  # Isn't this the same as `blackness`?
  # If not, it will be so confusing.
  @property 'black',
    get: -> @cmyka[3]
    set: (value) ->
      cmyka = @cmyka
      cmyka[3] = value
      @cmyka = cmyka

  @property 'luminance',
    get: -> .2126 * @red + .7152 * @green + .0722 * @blue

  isEqual: (other) ->
    other instanceof Color and
    other.red is @red and
    other.green is @green and
    other.blue is @blue and
    other.alpha is @alpha

  isEmpty: -> @alpha is 0

  blend: (backdrop, mode) -> @constructor.blend @, backdrop, mode

  clone: (red = @red, green = @green, blue = @blue, alpha = @alpha, etc...) ->
    super red, green, blue, alpha, etc...

  '.channel': (channel) ->
    unless channel in CHANNELS
      throw new Error "Cannot get channel #{channel} of color"

    if channel is 'hue'
      new Number @[channel] * 360, 'deg'
    else if channel is 'alpha'
      new Number @[channel]
    else
      new Number 100 * @[channel], '%'

  '.channel=': (channel, value) ->
    unless channel in CHANNELS
      throw new Error "Cannot get channel #{channel} of color"

    if value instanceof Number
      if value.unit is '%'
        @[channel] = value.value / 100
      else if value.isPure()
        if channel isnt 'alpha'
          @[channel] = value.value / 255
      # TODO else if channel is 'hue'...
      else
        throw new Error "Bad #{channel} channel value: #{value.repr()}"

  '.channel?': (channel) ->
    if channel in CHANNELS
      Boolean.new @[channel] > 0
    else
      throw new Error "Cannot check channel #{channel} of color"

  CHANNELS.forEach (channel) =>
    @::[".#{channel}"]  = -> @['.channel'] channel
    @::[".#{channel}?"] = -> @['.channel?'] channel
    @::[".#{channel}="] = (etc...) -> @['.channel='] channel, etc...

  '.transparent?': -> Boolean.new @isEmpty()

  '.transparent': -> @clone null, null, null, 0

  '.opaque?': -> Boolean.new @alpha is 1

  '.opaque': -> @clone null, null, null, 1

  '.saturate': (amount) ->
    unless amount?
      amount = 1
    else
      unless amount instanceof Number and amount.unit is '%'
        throw new TypeError "Bad value for Color.saturate"
      amount = amount.value / 100

    that = @clone()
    that.saturation = min 1, (max 0, that.saturation * (1 + amount))
    that

  '.desaturate': (amount) ->
    unless amount?
      amount = 1
    else
      unless amount instanceof Number and amount.unit is '%'
        throw new TypeError "Bad value for Color.saturate"
      amount = amount.value / 100

    that = @clone()
    that.saturation = min 1, (max 0, that.saturation - that.saturation * amount)
    that

  '.light?': -> Boolean.new @lightness >= .5

  '.dark?': -> Boolean.new @lightness < .5

  '.grey?': -> Boolean.new (@red is @blue and @blue is @green)

  '.gray?': @::['.grey?']

  '.spin': (amount) ->
    unless amount instanceof Number
      throw new TypeError "Bad value for Color.spin"

    unless amount.isPure()
      amount = amount.convert('deg')

    that = @clone()
    hue = that.hue * 360 + amount.value
    hue = hue % 360
    hue += 360 if hue < 0
    hue = hue / 360
    that.hue = hue
    that

  # TODO
  # http://dev.w3.org/csswg/css-color/#tint-shade-adjusters
  '.tint': ->

  '.shade': ->

  '.contrast': ->

  # https://www.w3.org/TR/WCAG20/#relativeluminancedef
  '.luminance': ->
    new Number 100 * @luminance, '%'

  '.luminance?': ->
    Boolean.new @luminance > 0

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

module.exports = Color
