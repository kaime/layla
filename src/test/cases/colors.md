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
    foo: #f.true? (#a7 and true) (#0000 or true) #000.true? #fff0.true? #00000000.true?
  }
  ~~~

  ~~~ css
  color.true {
    foo: true true #00000000 true true true;
  }
  ~~~

## Methods

### `transparent?`

- Returns `true` if the color is fully transparent

  ~~~ lay
  color.transparent {
    i: #000.transparent?
    ii: #0.transparent?
    iii: #000f.transparent?
    iv: #0000.transparent?
    v: not #000f.transparent?
    vi: #0000.transparent?
    vii: #aabbcc01.transparent?
    viii: #aabbccfe.transparent?
  }
  ~~~

  ~~~ css
  color.transparent {
    i: false;
    ii: false;
    iii: false;
    iv: true;
    v: true;
    vi: true;
    vii: false;
    viii: false;
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
    i: #000.opaque?
    ii: #000d.opaque?
    iii: #0000.opaque?
    iv: #000f.opaque?
    v: #aabbcc01.opaque?
    vi: #aabbccfe.opaque?
  }
  ~~~

  ~~~ css
  color.opaque {
    i: true;
    ii: false;
    iii: false;
    iv: true;
    v: false;
    vi: false;
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

### `saturate`

- Returns a saturated copy of the color

  ~~~ lay
  color.saturate {
    i: #29332f.saturate(20%)
  }
  ~~~

  ~~~ css
  color.saturate {
    i: #203c31;
  }
  ~~~

### `desaturate`

- Returns a desaturated copy of the color

  ~~~ lay
  color.desaturate {
    i: #203c31.desaturate(20%)
    ii: #203c31.desaturate
    iii: #203c31.desaturate(100%)
  }
  ~~~

  ~~~ css
  color.desaturate {
    i: #29332f;
    ii: #2e2e2e;
    iii: #2e2e2e;
  }
  ~~~

- When called with no arguments, returns a completely desaturated color

### `grey`/`gray`

- Are alias of `desaturate`

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

### `darken`

- Returns a copy of the color with decreased lightnes

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
    i: #bf6b40;
    ii: #80ff00;
  }
  ~~~

### `invert`

- Returns the invert color

  ~~~ lay
  color.invert {
    i: #437a86.invert
    ii: #0.invert
    iii: #f.invert
    iv: #000d.invert
    v: #ffff.invert
  }
  ~~~

  ~~~ css
  color.invert {
    i: #bc8579;
    ii: #ffffff;
    iii: #000000;
    iv: #ffffffdd;
    v: #000000;
  }
  ~~~

### `tint`

- Mixes the color with pure white

  ~~~ lay
  color.tint {
    i: #777777.tint(13)
    ii: #777777.tint(100)
    iii: #777777.tint(13%)
    iv: #777777.tint(-13%)
  }
  ~~~

  ~~~ css
  color.tint {
    i: #898989;
    ii: #ffffff;
    iii: #898989;
    iv: #656565;
  }
  ~~~

### `shade`

- Mixes the color with pure black

  ~~~ lay
  color.shade {
    i: #777777.shade(13)
    ii: #777777.shade(100)
    iii: #777777.shade(13%)
    iv: #777777.shade(-13%)
  }
  ~~~

  ~~~ css
  color.shade {
    i: #686868;
    ii: #000000;
    iii: #686868;
    iv: #868686;
  }
  ~~~

### `whiten`
### `blacken`

### `contrast`

### `blend`

- Blends a color onto another one using given method

  ~~~ lay
  color.blend {
    multiply: #f60000.blend(#f60000, 'multiply')
    screen: #f60000.blend(#0000f6, 'screen')
    overlay: #f60000.blend(#0000f6, 'overlay')
    soft-light: #f60000.blend(#ffffff, 'soft-light')
    hard-light: #f60000.blend(#0000f6, 'hard-light')
    difference: #f60000.blend(#0000f6, 'difference')
    exclusion: #f60000.blend(#0000f6, 'exclusion')
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
    i: #000 is #000
    ii: #000 is #000000
    iii: #000 isnt red
    iv: #f02 is #ff0022
    vi: #f02 is #ff0022ff
    vi: #f02e isnt #ff0022ff
    vii: not (#f02 isnt #ff0022)
  }
  ~~~

  ~~~ css
  color.is {
    i: true;
    ii: true;
    iii: true;
    iv: true;
    vi: true;
    vi: true;
    vii: true;
  }
  ~~~

### `+`

- Mixes two colors
