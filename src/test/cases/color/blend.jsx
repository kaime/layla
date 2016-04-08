#target photoshop

/**
 * This PS script automatically creates the test cases for `Color.blend` based
 * on *actual Photoshop results*. It:
 *
 * - Creates a new 1x1 RGB document in PS.
 * - Adds a new layer.
 * - Reads a list of colors defined in `samples.json`.
 * - Fills the layer (`source`) and background (`backdrop`) with combinations of
 *   the samples, sets the source layer opacity to the same value as the source
 *   color alpha and gets the computed color using the color sampler.
 * - Composes a `.md` test case based on the sample colors and the collected
 *   results.
 * - Opens a dialog asking where to save the `.md` file to.
 *
 * This is regular JavaScript, despite the `.jsx` extension. Tested on Photoshop
 * CS 6 & Windows 7.
 */

/**
 * `Array.prototype.map` polyfill.
 * https://developer.mozilla.org/docs/Web/JavaScript/Reference/Global_Objects/Array/map
 */
if (!Array.prototype.map) {

  Array.prototype.map = function(fun /*, thisArg */) {

    if (this === void 0 || this === null)
      throw new TypeError();

    var t = Object(this);
    var len = t.length >>> 0;
    if (typeof fun !== "function")
      throw new TypeError();

    var res = new Array(len);
    var thisArg = arguments.length >= 2 ? arguments[1] : void 0;
    for (var i = 0; i < len; i++)
    {
      // NOTE: Absolute correctness would demand Object.defineProperty
      //       be used.  But this method is fairly new, and failure is
      //       possible only if Object.prototype or Array.prototype
      //       has a property |i| (very unlikely), so use a less-correct
      //       but more portable alternative.
      if (i in t)
        res[i] = fun.call(thisArg, t[i], i, t);
    }

    return res;
  };
}

/**
 * This tells the path of this script.
 *
 * From http://www.ps-scripts.com/bb/viewtopic.php?f=2&t=3446
 */
function whereAmI() {

  var where;

  try {
    var forcedError = FORCEDRRROR;
  } catch (e) {
    where = File(e.fileName).parent;
  }

  return where;
}



var ROMANS = {
    M:  1000,
    CM:  900,
    D:   500,
    CD:  400,
    C:   100,
    XC:   90,
    L:    50,
    XL:   40,
    X:    10,
    IX:    9,
    V:     5,
    IV:    4,
    I:     1
  }

function roman(n) {
  return n;
}

/**
 * Pairs `Color.blend` modes with PS ones.
 */
var MODES = {
  'normal':      BlendMode.NORMAL,
  'multiply':    BlendMode.MULTIPLY,
  'screen':      BlendMode.SCREEN,
  'overlay':     BlendMode.OVERLAY,
  'darken':      BlendMode.DARKEN,
  'lighten':     BlendMode.LIGHTEN,
  'color-dodge': BlendMode.COLORDODGE,
  'color-burn':  BlendMode.COLORBURN,
  'hard-light':  BlendMode.HARDLIGHT,
  'soft-light':  BlendMode.SOFTLIGHT,
  'difference':  BlendMode.DIFFERENCE,
  'exclusion':   BlendMode.EXCLUSION,
  'hue':         BlendMode.HUE,
  'saturation':  BlendMode.SATURATION,
  'color':       BlendMode.COLORBLEND,
  'luminosity':  BlendMode.LUMINOSITY
};

/**
 * CSSColor class. Represents an RGBA color.
 */
function CSSColor(r, g, b, a) {

  if (typeof a === 'undedined') a = 1;

  this.red = parseFloat(r);
  this.green = parseFloat(g);
  this.blue = parseFloat(b);
  this.alpha = parseFloat(a);
}

/**
 * Parses a rgb(a) CSS color.
 */
CSSColor.parseRGBA = (function() {

  var regRGBA = /^\s*rgba?\s*\(\s*([0-9\.]+)\s*,\s*([0-9\.]+)\s*,\s*([0-9\.]+)\s*(?:,\s*([0-9\.]+\s*(%?)))?\s*\)\s*$/i;

  return function(rgba) {

    var m = rgba.match(regRGBA);

    if (m) {

      var alpha = 1;

      if (m.length > 4) {
        alpha = parseFloat(m[4]);
        if (m[5] === '%') {
          alpha /= 100;
        }
      }

      return new CSSColor(m[1], m[2], m[3], alpha);
    }
  }

})();

/**
 * Parses an hexadecimal CSS color.
 */
CSSColor.parseHex = (function() {

  var regHex = new RegExp([
    '^\\s*#',
    '([0-9a-f]{2})',
    '([0-9a-f]{2})',
    '([0-9a-f]{2})',
    '\\s*$'
  ].join(''), 'i');

  return function(hex) {
    var m = hex.match(regHex);

    if (m) {
      return new CSSColor(
          parseInt(m[1], 16),
          parseInt(m[2], 16),
          parseInt(m[3], 16),
          1
      );
    }

    return null;
  }

})()


/**
 * Parses a CSS named color.
 */
CSSColor.parseNamed = function(color) {

    var colors = {
     "aliceblue": "#f0f8ff",
     "antiquewhite": "#faebd7",
     "aqua": "#00ffff",
     "aquamarine": "#7fffd4",
     "azure": "#f0ffff",
     "beige": "#f5f5dc",
     "bisque": "#ffe4c4",
     "black": "#000000",
     "blanchedalmond": "#ffebcd",
     "blue": "#0000ff",
     "blueviolet": "#8a2be2",
     "brown": "#a52a2a",
     "burlywood": "#deb887",
     "cadetblue": "#5f9ea0",
     "chartreuse": "#7fff00",
     "chocolate": "#d2691e",
     "coral": "#ff7f50",
     "cornflowerblue": "#6495ed",
     "cornsilk": "#fff8dc",
     "crimson": "#dc143c",
     "cyan": "#00ffff",
     "darkblue": "#00008b",
     "darkcyan": "#008b8b",
     "darkgoldenrod": "#b8860b",
     "darkgray": "#a9a9a9",
     "darkgrey": "#a9a9a9",
     "darkgreen": "#006400",
     "darkkhaki": "#bdb76b",
     "darkmagenta": "#8b008b",
     "darkolivegreen": "#556b2f",
     "darkorange": "#ff8c00",
     "darkorchid": "#9932cc",
     "darkred": "#8b0000",
     "darksalmon": "#e9967a",
     "darkseagreen": "#8fbc8f",
     "darkslateblue": "#483d8b",
     "darkslategray": "#2f4f4f",
     "darkslategrey": "#2f4f4f",
     "darkturquoise": "#00ced1",
     "darkviolet": "#9400d3",
     "deeppink": "#ff1493",
     "deepskyblue": "#00bfff",
     "dimgray": "#696969",
     "dimgrey": "#696969",
     "dodgerblue": "#1e90ff",
     "firebrick": "#b22222",
     "floralwhite": "#fffaf0",
     "forestgreen": "#228b22",
     "fuchsia": "#ff00ff",
     "gainsboro": "#dcdcdc",
     "ghostwhite": "#f8f8ff",
     "gold": "#ffd700",
     "goldenrod": "#daa520",
     "gray": "#808080",
     "grey": "#808080",
     "green": "#008000",
     "greenyellow": "#adff2f",
     "honeydew": "#f0fff0",
     "hotpink": "#ff69b4",
     "indianred ": "#cd5c5c",
     "indigo ": "#4b0082",
     "ivory": "#fffff0",
     "khaki": "#f0e68c",
     "lavender": "#e6e6fa",
     "lavenderblush": "#fff0f5",
     "lawngreen": "#7cfc00",
     "lemonchiffon": "#fffacd",
     "lightblue": "#add8e6",
     "lightcoral": "#f08080",
     "lightcyan": "#e0ffff",
     "lightgoldenrodyellow": "#fafad2",
     "lightgrey": "#d3d3d3",
     "lightgreen": "#90ee90",
     "lightpink": "#ffb6c1",
     "lightsalmon": "#ffa07a",
     "lightseagreen": "#20b2aa",
     "lightskyblue": "#87cefa",
     "lightslategray": "#778899",
     "lightslategrey": "#778899",
     "lightsteelblue": "#b0c4de",
     "lightyellow": "#ffffe0",
     "lime": "#00ff00",
     "limegreen": "#32cd32",
     "linen": "#faf0e6",
     "magenta": "#ff00ff",
     "maroon": "#800000",
     "mediumaquamarine": "#66cdaa",
     "mediumblue": "#0000cd",
     "mediumorchid": "#ba55d3",
     "mediumpurple": "#9370d8",
     "mediumseagreen": "#3cb371",
     "mediumslateblue": "#7b68ee",
     "mediumspringgreen": "#00fa9a",
     "mediumturquoise": "#48d1cc",
     "mediumvioletred": "#c71585",
     "midnightblue": "#191970",
     "mintcream": "#f5fffa",
     "mistyrose": "#ffe4e1",
     "moccasin": "#ffe4b5",
     "navajowhite": "#ffdead",
     "navy": "#000080",
     "oldlace": "#fdf5e6",
     "olive": "#808000",
     "olivedrab": "#6b8e23",
     "orange": "#ffa500",
     "orangered": "#ff4500",
     "orchid": "#da70d6",
     "palegoldenrod": "#eee8aa",
     "palegreen": "#98fb98",
     "paleturquoise": "#afeeee",
     "palevioletred": "#d87093",
     "papayawhip": "#ffefd5",
     "peachpuff": "#ffdab9",
     "peru": "#cd853f",
     "pink": "#ffc0cb",
     "plum": "#dda0dd",
     "powderblue": "#b0e0e6",
     "purple": "#800080",
     "red": "#ff0000",
     "rosybrown": "#bc8f8f",
     "royalblue": "#4169e1",
     "saddlebrown": "#8b4513",
     "salmon": "#fa8072",
     "sandybrown": "#f4a460",
     "seagreen": "#2e8b57",
     "seashell": "#fff5ee",
     "sienna": "#a0522d",
     "silver": "#c0c0c0",
     "skyblue": "#87ceeb",
     "slateblue": "#6a5acd",
     "slategrey": "#708090",
     "slategrey": "#708090",
     "snow": "#fffafa",
     "springgreen": "#00ff7f",
     "steelblue": "#4682b4",
     "tan": "#d2b48c",
     "teal": "#008080",
     "thistle": "#d8bfd8",
     "tomato": "#ff6347",
     "turquoise": "#40e0d0",
     "violet": "#ee82ee",
     "wheat": "#f5deb3",
     "white": "#ffffff",
     "whitesmoke": "#f5f5f5",
     "yellow": "#ffff00",
     "yellowgreen": "#9acd32"
  };

  color = color.toLowerCase();

  if (color in colors) {
    return CSSColor.parseHex(colors[color]);
  }

  return null;
}

/**
 * Parses a `grey()` color.
 */
CSSColor.parseGrey = (function() {

  var regGrey = /^\s*gr[ea]y\s*\(([0-9\.]+)(%?)\s*(?:,([0-9\.]+)(%?))?\s*\)\s*$/i

  return function(color) {

    var m = color.match(regGrey);

    if (m) {

      var g = parseFloat(m[1]);

      if (m[2] === '%') {
        g /= 100;
      }

      g = 1 - g;

      var alpha = 1;

      if (typeof m[3] !== 'undefined') {
        alpha = parseFloat(m[3]);

        if (m[4] === '%') {
          alpha /= 100;
        }
      }

      return new CSSColor(
        g * 255, g * 255, g * 255, alpha
      );
    }
  }

})();

/**
 * Parses a named, rgb(a) or hexadecimal CSS color.
 */
CSSColor.parse = function(color) {
  return CSSColor.parseNamed(color) || CSSColor.parseGrey(color) || CSSColor.parseRGBA(color) || CSSColor.parseHex(color);
}

/**
 * Creates a new `CSSColor` from a PS `solidColor` and an optional `alpha`
 * value.
 */
CSSColor.fromPS = function(color, alpha) {
  if (typeof alpha === 'undefined') alpha = 1;

  return new CSSColor(
    color.rgb.red,
    color.rgb.green,
    color.rgb.blue,
    1
  );
}

/**
 * Returns equivalent (opaque) PS `solidColor`.
 */
CSSColor.prototype.toPS = function() {
  var color = new SolidColor;

  color.rgb.red = this.red;
  color.rgb.green = this.green;
  color.rgb.blue = this.blue;

  return color;
}

CSSColor.prototype.toString = function() {

  var r = Math.round(this.red),
      g = Math.round(this.green),
      b = Math.round(this.blue);

  if (this.alpha < 1) {
    return 'rgba(' +
      r +
      ', ' + g +
      ', ' + b +
      ', ' + this.alpha +
    ')';
  }

  var hex = [r, g, b].map(
    function(c) {
      return ('0' + c.toString(16).toLowerCase()).substr(-2);
    }
  );

  for (var i = 0; i < 3; i++) {
    if (hex[i].charAt(0) !== hex[i].charAt(1)) {
      // Long #XXXXXX form
      return '#' + hex[0] + hex[1] + hex[2];
    }
  }

  // Abbreviated #XXX form
  return '#' + hex[0].charAt(0) + hex[1].charAt(0) + hex[2].charAt(0);
}

/**
 * Parses a JSON string.
 */
function parseJSON(json) {
  return eval('(' + json + ')');
}

/**
 * Reads and parses a JSON file.
 */
function readJSON(path) {
  var file = File(whereAmI() + path);

  if (file.exists) {
    file.open('r');
    var json = file.read();
    file.close();
    return parseJSON(json);
  }
}

// Read samples from JSON file.
var samples = readJSON('./samples.json');

// Actual Layla code.
var code = [];

// Keep old Photoshop settings...
var oldSettings = {
  rulerUnits: app.preferences.rulerUnits,
  displayDialogs: app.displayDialogs
}

// ...before setting custom preferences.
preferences.rulerUnits = Units.PIXELS;
app.displayDialogs = DialogModes.NO;

// Create the doc. We only need 1px.
var doc = app.documents.add(1, 1);
//doc.bitsPerChannel = BitsPerChannelType.EIGHT;
//doc.bitsPerChannel = BitsPerChannelType.SIXTEEN;
doc.bitsPerChannel = BitsPerChannelType.THIRTYTWO;

// Add a color sampler to query result color
var sampler = doc.colorSamplers.add([0, 0]);

// "Backdrop" layer.
var backdropLayer = doc.backgroundLayer;

// Create the "source" layer.
var sourceLayer = doc.artLayers.add();

// Select the *whole* pixel.
doc.selection.selectAll();

// Blend each color with each other.
var mode, i, r, j, l = samples.length, source, result, lay, css;

for (mode in MODES) {

  try {

    // This blend mode could not be available in working color mode
    sourceLayer.blendMode = MODES[mode];

    // This is the Layla code
    lay = [];

    // This is the (expected) CSS code
    css = [];

    for (i = 0; i < l; i++) {

      // The backdrop color.
      backdrop = CSSColor.parse(samples[i]);

      // Apply to backdrop layer.
      doc.activeLayer = backdropLayer;
      doc.selection.fill(backdrop.toPS());

      for (j = 0; j < l; j++) {

        try {
          // The source color.
          source = CSSColor.parse(samples[j]);

          // Apply to source layer.
          doc.activeLayer = sourceLayer;
          doc.selection.fill(source.toPS());
          sourceLayer.opacity = source.alpha * 100;

          // Collect computed result.
          result = CSSColor.fromPS(sampler.color);

        } catch (e) {
          continue;
        }

        r = roman(i);

        // Append to Layla code.
        lay.push(
          r + ': ' + samples[j] +
          "blend('" + samples[i] + "', " + mode + ')'
        );

        // Append to expected CSS code
        css.push(
          r + ': ' + result + ';'
        );
      }
    }

  } catch (e) {
    continue;
  }

  function indent(lines) {
    return lines.map(function(line) {
      return '  ' + line;
    });
  }

  code = code.concat(
    ['- `' + mode + '`'],
    ['', '  ~~~ lay'],
    indent(lay),
    ['', '  ~~~']
    ['', '  ~~~ css'],
    indent(css),
    ['', '  ~~~', '', '']
  );
}

// Almost done. Restore preferences now.
app.preferences.rulerUnits = oldSettings.rulerUnits;
app.displayDialogs = oldSettings.displayDialogs;

// And silently close document.
doc.close(SaveOptions.DONOTSAVECHANGES);

// Open save dialog and write code if not cancelled
var file = File.saveDialog('Save test case', "Layla:*.lay");

if (file) {
  code = code.join("\n");
  file.open('w');
  file.write(code);
  file.close();
}
