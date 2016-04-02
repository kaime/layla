# Colors

- Are expressed with hexadecimal notation

  ~~~ lay
  color[hex] {
    color: #a2f
    color: #666
    color: #fefefe
  }
  ~~~

  ~~~ css
  color[hex] {
    color: #aa22ff;
    color: #666666;
    color: #fefefe;
  }
  ~~~

- Can have 6 digits

  ~~~ lay
  color[hex=6] {
    six: #000000
    six: #ffffff
    six: #a7cb82
  }
  ~~~

  ~~~ css
  color[hex=6] {
    six: #000000;
    six: #ffffff;
    six: #a7cb82;
  }
  ~~~

- Can have 3 digits

  ~~~ lay
  color[hex=3] {
    three: #000
    three: #fff
    three: #7ab
  }
  ~~~

  ~~~ css
  color[hex=3] {
    three: #000000;
    three: #ffffff;
    three: #77aabb;
  }
  ~~~

- Can have 8 digits

  ~~~ lay
  color[hex=8] {
    eight: #00000000
    eight: #ffffffff
    eight: #a7cb82ab
  }
  ~~~

  ~~~ css
  color[hex=8] {
    eight: #00000000;
    eight: #ffffff;
    eight: #a7cb82ab;
  }
  ~~~

- Can have 4 digits

  ~~~ lay
  color[hex=4] {
    four: #0000
    four: #000a
    four: #ffff
    four: #b78c
  }
  ~~~

  ~~~ css
  color[hex=4] {
    four: #00000000;
    four: #000000aa;
    four: #ffffff;
    four: #bb7788cc;
  }
  ~~~

- Can have 2 digits

  ~~~ lay
  color[hex=2] {
    two: #00
    two: #ff
    two: #3a
  }
  ~~~

  ~~~ css
  color[hex=2] {
    two: #000000;
    two: #ffffff;
    two: #3a3a3a;
  }
  ~~~

- Can have 1 single digit

  ~~~ lay
  color[hex=1] {
    one: #0
    one: #f
    one: #3
  }
  ~~~

  ~~~ css
  color[hex=1] {
    one: #000000;
    one: #ffffff;
    one: #333333;
  }
  ~~~

- Are always trueish

  ~~~ lay
  color.true {
    foo: #f.true? (#a7 and true) #000.true? #fff0.true? #00000000.true?
  }
  ~~~

  ~~~ css
  color.true {
    foo: true true true true true;
  }
  ~~~

## Methods

### `transparent?`

- Returns `true` if the color is fully transparent

  ~~~ lay
  color.transparent {
    foo: #000.transparent?
    foo: #0.transparent?
    foo: #000f.transparent?
    foo: #0000.transparent?
    foo: not #000f.transparent?
    foo: #0000.transparent?
  }
  ~~~

  ~~~ css
  color.transparent {
    foo: false;
    foo: false;
    foo: false;
    foo: true;
    foo: true;
    foo: true;
  }
  ~~~

### `transparent`

- Returns a fully transparent version of the color

  ~~~ lay
  color.transparent {
    foo: #000.transparent
    foo: #000d.transparent
    foo: #000f.transparent
    foo: #fa2a.transparent
    foo: #b271acf2.transparent
  }
  ~~~

  ~~~ css
  color.transparent {
    foo: #00000000;
    foo: #00000000;
    foo: #00000000;
    foo: #ffaa2200;
    foo: #b271ac00;
  }
  ~~~

### `empty?`

- Is an alias of `transparent?`

  ~~~ lay
  color.empty {
    foo: (not #000f.empty?) #0000.empty?
  }
  ~~~

  ~~~ css
  color.empty {
    foo: true true;
  }
  ~~~

### `opaque?`

- Returns `true` if the color is fully opaque

  ~~~ lay
  color.opaque {
    foo: #000.opaque?
    foo: #000d.opaque?
    foo: #0000.opaque?
    foo: #000f.opaque?
  }
  ~~~

  ~~~ css
  color.opaque {
    foo: true;
    foo: false;
    foo: false;
    foo: true;
  }
  ~~~

### `opaque`

- Returns a fully opaque version of the color

  ~~~ lay
  color.opaque {
    foo: #000.opaque
    foo: #000d.opaque
    foo: #fa2a.opaque
    foo: #b271acf2.opaque
  }
  ~~~

  ~~~ css
  color.opaque {
    foo: #000000;
    foo: #000000;
    foo: #ffaa22;
    foo: #b271ac;
  }
  ~~~

### `alpha`

- Returns the alpha channel of the color as a decimal number between 0..1

  ~~~ lay
  color.alpha {
    transparency: #f000.alpha #000000b3.alpha #fc3ad0.alpha #ad0fb13f.alpha
  }
  ~~~

  ~~~ css
  color.alpha {
    transparency: 0 0.7 1 0.25;
  }
  ~~~

### `alpha=`

- Sets the alpha channel of the color

  ~~~ lay
  color.alpha {
    a = #f000
    b = #000000b3
    c = #fc3ad0
    d = #ad0fb101

    I: a a.alpha, b b.alpha, c c.alpha, d d.alpha

    a.alpha = 100%
    b.alpha = 0%
    c.alpha = 27%
    d.alpha = 99%

    II: a a.alpha, b b.alpha, c c.alpha, d d.alpha
  }
  ~~~

  ~~~ css
  color.alpha {
    I: #ff000000 0, #000000b3 0.7, #fc3ad0 1, #ad0fb101 0;
    II: #ff0000 1, #00000000 0, #fc3ad045 0.27, #ad0fb1fc 0.99;
  }
  ~~~

- Only accepts a percentage or a pure number in the 0..255 range

### `alpha?`

- Returns `true` if the alpha of the color is greater than `0`

  ~~~ lay
  color.alpha {
    foo: #000.alpha?
    foo: not #fa76cc.alpha?
  }
  ~~~

  ~~~ css
  color.alpha {
    foo: true;
    foo: false;
  }
  ~~~

### `red`

- Returns the red channel of the color as a percentage

  ~~~ lay
  color.red {
    red: #f000.red #000.red #fc3ad0.red
  }
  ~~~

  ~~~ css
  color.red {
    red: 100% 0 98.82%;
  }
  ~~~

### `red=`

- Sets the red channel of the color

  ~~~ lay
  color.red {
    a = #f000
    b = #000
    c = #fc3ad0
    I: a a.red, b  b.red, c c.red
    a.red = 50%
    b.red = 100%
    c.red = 128
    II: a a.red, b b.red, c c.red
  }
  ~~~

  ~~~ css
  color.red {
    I: #ff000000 100%, #000000 0, #fc3ad0 98.82%;
    II: #80000000 50%, #ff0000 100%, #803ad0 50.2%;
  }
  ~~~

- Only accepts a percentage or a pure number in the 0..255 range

### `red?`

- Returns `true` if the red channel of the color is not `0`

  ~~~ lay
  color.red {
    foo: #000.red?
    foo: #110.red?
    foo: #ffffff.red?
  }
  ~~~

  ~~~ css
  color.red {
    foo: false;
    foo: true;
    foo: true;
  }
  ~~~

### `green`

- Returns the green channel of the color as a percentage

  ~~~ lay
  color.green {
    green: #0f0.green #000.green #fc3ad0.green
  }
  ~~~

  ~~~ css
  color.green {
    green: 100% 0 22.75%;
  }
  ~~~

### `green=`

- Sets the green channel of the color

  ~~~ lay
  a = #0f00
  b = #000
  c = #fc3ad0
  color.green {
    I: a a.green, b  b.green, c c.green
    a.green = 50%
    b.green = 100%
    c.green = 128
    II: a a.green, b b.green, c c.green
  }
  ~~~

  ~~~ css
  color.green {
    I: #00ff0000 100%, #000000 0, #fc3ad0 22.75%;
    II: #00800000 50%, #00ff00 100%, #fc80d0 50.2%;
  }
  ~~~

- Only accepts a percentage or a pure number in the 0..255 range

### `green?`

- Returns `true` if the green channel of the color is not `0`

  ~~~ lay
  color.green {
    foo: #000.green?
    foo: #010.green?
    foo: #ffffff.green?
  }
  ~~~

  ~~~ css
  color.green {
    foo: false;
    foo: true;
    foo: true;
  }
  ~~~

### `blue`

- Returns the blue channel of the color as a percentage

  ~~~ lay
  color.blue {
    blue: #00f.blue #000.blue #fc3ad0.blue
  }
  ~~~

  ~~~ css
  color.blue {
    blue: 100% 0 81.57%;
  }
  ~~~

### `blue=`

- Sets the blue channel of the color

  ~~~ lay
  color.blue {
    a = #00f0
    b = #000
    c = #fc3ad0
    I: a a.blue, b  b.blue, c c.blue
    a.blue = 50%
    b.blue = 100%
    c.blue = 128
    II: a a.blue, b b.blue, c c.blue
  }
  ~~~

  ~~~ css
  color.blue {
    I: #0000ff00 100%, #000000 0, #fc3ad0 81.57%;
    II: #00008000 50%, #0000ff 100%, #fc3a80 50.2%;
  }
  ~~~

- Only accepts a percentage or a pure number in the 0..255 range

### `blue?`

- Returns `true` if the blue channel of the color is not `0`

  ~~~ lay
  color.blue {
    foo: #000.blue?
    foo: #7a0.blue?
    foo: #70a.blue?
    foo: #ffffff.blue?
  }
  ~~~

  ~~~ css
  color.blue {
    foo: false;
    foo: false;
    foo: true;
    foo: true;
  }
  ~~~

### `grey?`

- Return `true` if the color is white, black or a shade of grey

  ~~~ lay
  color.grey {
    foo: #000.grey?
    foo: #666.grey?
    foo: #f07.grey?
    foo: #ffffff.grey?
  }
  ~~~

  ~~~ css
  color.grey {
    foo: true;
    foo: true;
    foo: false;
    foo: true;
  }
  ~~~

### `gray?`

- Is an alias of `grey?`

  ~~~ lay
  color.gray {
    foo: #000.gray? #666.gray? #f07.gray? #ffffff.gray?
  }
  ~~~

  ~~~ css
  color.gray {
    foo: true true false true;
  }
  ~~~

### `hue`

- Returns the hue channel of the color in degrees

  ~~~ lay
  color.hue {
    hue: #fa20.hue
    hue: #000.hue
    hue: #fff.hue
    hue: #db0.hue
  }
  ~~~

  ~~~ css
  color.hue {
    hue: 36.92deg;
    hue: 0;
    hue: 0;
    hue: 50.77deg;
  }
  ~~~

### `hue=`

- Sets the hue of the color

- Only accepts a pure number in the 0..255 range, a percentage or an angle

### `hue?`

### `saturation`

- Returns the saturation channel of the color as a percentage

  ~~~ lay
  color.saturation {
    sat: #fa20.saturation
    sat: #000.saturation
    sat: #fff.saturation
    sat: #22b.saturation
    sat: #FF4500.saturation
    sat: #57220fdd.saturation.round
    sat: #a6e548.saturation.round
  }
  ~~~

  ~~~ css
  color.saturation {
    sat: 100%;
    sat: 0;
    sat: 0;
    sat: 69.23%;
    sat: 100%;
    sat: 71%;
    sat: 75%;
  }
  ~~~

### `saturation=`

- Sets the saturation of the color

- Only accepts a percentage or a pure number in the 0..255 range

### `saturation?`

### `saturate`

- Returns a relatively saturated copy of the color

  ~~~ lay
  color.saturate {
    i: #c33.saturate(40%)
  }
  ~~~

  ~~~ css
  color.saturate {
    i: #eb1414;
  }
  ~~~

- Only accepts a percentage as argument

### `desaturate`

- Returns a relatively desaturated copy of the color

  ~~~ lay
  color.saturate {
    i: #c33.desaturate(40%)
  }
  ~~~

  ~~~ css
  color.saturate {
    i: #ad5252;
  }
  ~~~

- When called with no arguments, returns a completely desaturated color

- Only accepts a percentage as argument

### `grey`/`gray`

- Are alias of `desaturate`

### `lightness`

- Returns the lightness of the color as a percentage

  ~~~ lay
  color.lightness {
    light: #fa20.lightness
    light: #000.lightness
    light: #fff.lightness
    light: #22b.lightness
  }
  ~~~

  ~~~ css
  color.lightness {
    light: 56.67%;
    light: 0;
    light: 100%;
    light: 43.33%;
  }
  ~~~

### `lightness=`

- Sets the lightness of the color

- Only accepts a percentage or a pure number in the 0..255 range

### `lightness?`

- Returns `true` if the color has any lightness (ie: its lightness is > 0)

### `light?`

- Tells if the color is light (ie: its lightness is >= 50%)

  ~~~ lay
  color.light {
    foo: #000.light?
    foo: #ffff.light?
    foo: #00ff40.light?
    foo: #333.light?
  }
  ~~~

  ~~~ css
  color.light {
    foo: false;
    foo: true;
    foo: true;
    foo: false;
  }
  ~~~

### `dark?`

- Tells if the color is dark (ie: its lightness is < 50%)

  ~~~ lay
  color.dark {
    foo: #000.dark?
    foo: #ffff.dark?
    foo: #00ff40.dark?
    foo: #333.dark?
  }
  ~~~

  ~~~ css
  color.dark {
    foo: true;
    foo: false;
    foo: false;
    foo: true;
  }
  ~~~

### `luminance`

- Returns the relative luminance of the color as a percentage

  ~~~ lay
  color.luminance {
    i: #fff.luminance
    ii: #000.luminance
    iii: #f00.luminance
    iv: #f00a.luminance
    v: #00ff00.luminance
    vi: #0000ff.luminance
    vii: #ffff00.luminance
    viii: #00ffff.luminance
    ix: #ff0000.luminance
  }
  ~~~

  ~~~ css
  color.luminance {
    i: 100%;
    ii: 0;
    iii: 21.26%;
    iv: 21.26%;
    v: 71.52%;
    vi: 7.22%;
    vii: 92.78%;
    viii: 78.74%;
    ix: 21.26%;
  }
  ~~~

### `luminance?`

- Returns `true` if the color has any luminance (ie: its luminance is > 0%)

  ~~~ lay
  color.luminance {
    i: #fff.luminance?
    ii: #000.luminance?
    iii: #f00.luminance?
    iv: #f00a.luminance?
    v: #00ff00.luminance?
    vi: #0000ff.luminance?
    vii: #ffff00.luminance?
    viii: #00ffff.luminance?
    ix: #ff0000.luminance?
    x: #0000.luminance?
    xi: #000f.luminance?
  }
  ~~~

  ~~~ css
  color.luminance {
    i: true;
    ii: false;
    iii: true;
    iv: true;
    v: true;
    vi: true;
    vii: true;
    viii: true;
    ix: true;
    x: false;
    xi: false;
  }
  ~~~

### `lighten`

- Returns a copy of the color with increased lightness

- Only accepts a percentage as argument

### `darken`

- Returns a copy of the color with decreased lightnes

- Only accepts a percentage as argument

### `spin`

- Rotates the hue angle of the color

  ~~~ lay
  color.spin {
    i: #bf406a.spin(40)
    ii: #ff0000.spin(90deg)
  }
  ~~~

  ~~~ css
  color.spin {
    i: #bf6a40;
    ii: #80ff00;
  }
  ~~~

- Only accepts...


### `whiteness`

- Returns the `whiteness` channel of the HWB color space

  ~~~ lay
  color.blackness {
    i: #000000.whiteness
    ii: #ffffff00.whiteness
    iii: #8cc864.whiteness
  }
  ~~~

  ~~~ css
  color.blackness {
    i: 0;
    ii: 100%;
    iii: 39.22%;
  }
  ~~~

### `whiteness=`

- Sets the `blackness` value on the HWB color space

### `whiteness?`

- Returns `true` if the `whiteness` channel is greater than 0

### `blackness`

- Returns the `blackness` channel of the HWB color space

  ~~~ lay
  color.blackness {
    i: #000000.blackness
    ii: #ffffff00.blackness
    iii: #8cc864.blackness
  }
  ~~~

  ~~~ css
  color.blackness {
    i: 100%;
    ii: 0;
    iii: 21.57%;
  }
  ~~~

### `blackness=`

- Sets the `blackness` value on the HWB color space

### `blackness?`

- Returns `true` if the `blackness` channel is greater than 0

### `cyan`

- Returns the `cyan` value on the CYMK color space

### `cyan=`

- Adjusts the `cyan` value on the CYMK color space

- Only accepts a percentage or a pure number in the 0..255 range

### `cyan?`

- Returns `true` if the color has any cyan (ie: its `cyan` value is > 0)

### `magenta`

- Returns the `magenta` value on the CYMK color space

### `magenta=`

- Adjusts the `magenta` value on the CYMK color space

- Only accepts a percentage or a pure number in the 0..255 range

### `magenta?`

- Returns `true` if the color has any magenta (ie: its `magenta` value is > 0)

### `yellow`

- Returns the `yellow` value on the CYMK color space

### `yellow=`

- Adjusts the `yellow` value on the CYMK color space

- Only accepts a percentage or a pure number in the 0..255 range

### `yellow?`

- Returns `true` if the color has any yellow (ie: its `yellow` value is > 0)

### `black`

- Returns the `black` value on the CYMK color space

### `black=`

- Adjusts the `black` value on the CYMK color space

- Only accepts a percentage or a pure number in the 0..255 range

### `black?`

- Returns `true` if the color has any black (ie: its `black` value is > 0)

### `tint`

### `shade`

### `contrast`

### `blend`

- Blends a color onto another one using given method

  ~~~ lay
  color.blend {
    multiply: #f60000.blend(#f60000, multiply)
    screen: #f60000.blend(#0000f6, screen)
    overlay: #f60000.blend(#0000f6, 'overlay')
    soft-light: #f60000.blend(#ffffff, soft-light)
    hard-light: #f60000.blend(#0000f6, hard-light)
    difference: #f60000.blend(#0000f6, "difference")
    exclusion: #f60000.blend(#0000f6, `exclusion`)
  }
  ~~~

  ~~~ css
  color.blend {
    multiply: #ed0000;
    screen: #f600f6;
    overlay: #ed0000;
    soft-light: #fa0000;
    hard-light: #0000ed;
    difference: #f600f6;
    exclusion: #f600f6;
  }
  ~~~

## Operators

### `is`

- Returns `true` only for colors with the same channels

  ~~~ lay
  color.is {
    foo: #000 is #000
    foo: #000 is #000000
    foo: #000 isnt red
    foo: #f02 is #ff0022
    foo: #f02 is #ff0022ff
    foo: #f02e isnt #ff0022ff
    foo: not (#f02 isnt #ff0022)
  }
  ~~~

  ~~~ css
  color.is {
    foo: true;
    foo: true;
    foo: true;
    foo: true;
    foo: true;
    foo: true;
    foo: true;
  }
  ~~~

### `+`

- Mixes two colors
