<div align="right">
  <a href="https://travis-ci.org/krokis/layla">
    <img src="https://img.shields.io/travis/krokis/layla/master.svg"/>
  </a>
</div>
<div align="center">
  <img src="https://raw.githubusercontent.com/kaime/layla/docs/layla.png" alt="Layla"/>
</div>


# Intro
Layla is (yet) another CSS language which should make your style sheets more dynamic, reusable, maintainable and compact. And your life easier.

Call it a *preprocessor* if you like, but, even tough Layla *looks like* CSS, it's actually an absurdly featured scripting language that *produces* valid CSS. And yes, it does the kind of things SASS, Less and Stylus do.

Layla supports most current CSS syntax, plus...

- [Optional semicolons](#optional-semicolons).
- [Nested blocks](#nested-blocks), both rule sets and at-rules.
- [Multiple](#multiple-property-declarations) and [conditional](#conditional-property-declarations) property declarations.
- [Line comments](#comments).
- [Variables](#variables) and expressions:
  * A wide collection of  [built-in types](#types): `Boolean`, `String`, `Number`,  `List`, `Range`, `Color`, `URL`, `Block`, `RegExp`, `RuleSet`, `AtRule`, `Property`, `Selector`, `Null`, and more.
  * A rich set of [operators](#operators): arithmetic, logical, comparison and other operators.
  * Over *160* built-in convenience [methods](#methods).
  * [Interpolation](#interpolation)
- Control structures:
  - [Conditionals](#conditionals):  `if`, `else (if)`.
  - [Loops](#loops): `while` and `for ... in`; `break` and `continue`.
- User [functions](#functions) with variadic and default arguments.
- [Custom units](#custom-units)
- Compile-time [`include`](#include)s.
- [Plug-in](#plugins) support.
- [Reflection](#reflection).
- And much more.

You can use Layla on the [command line](#from-the-command-line), [on the browser](#on-the-browser) or as a JavaScript library. It [behaves well](https://travis-ci.org/krokis/layla) on Node.js 0.12, 4 and up, Firefox, Chrome and many other [desktop and mobile browsers](#).

Layla is released under a permissive BSD-like [license](License.md), which fairly means you can use it on any project.

Want to know more? Read the following [overview](#overview) of the main features, or jump directly to:

- [Installation](#installation)
- [Usage](#usage)
- [Reference](#)


## Overview

This is only an overview of some of Layla's features. Go to the [language reference](#) for a deeper look.

<a name="optional-semicolons"></a>
#### Optional semicolons

You can omit the semicolon at the end of a line, as long as it makes a valid statement. This means you can generally forget about semicolons if you are sane enough to write each declaration on its own line:

~~~ lay
img.avatar {
  border: 2px solid #666
  margin: 0
}
~~~

~~~ css
img.avatar {
  border: 2px solid #666666;
  margin: 0;
}
~~~

But you can still use semicolons everywhere if you wish:

~~~ lay
body { background:white; }; img.avatar { border: 2px solid #666; margin: 0; };
~~~

~~~ css
body {
  background: white;
}

img.avatar {
  border: 2px solid #666666;
  margin: 0;
}
~~~

Note a line break will be treated as semicolon only if the preceding code makes a valid statement. You can still span a statement over multiple lines if you use parentheses or place an operator at the end of the line:

~~~ lay
button {
  color: rgba(
    255,
    255,
    255,
    .75
  )
  box-shadow:
    0 1px 4px black,
    inset 0 1px 2px silver
}
~~~

~~~ css
button {
  color: rgba(255, 255, 255, 0.75);
  box-shadow: 0 1px 4px black, inset 0 1px 2px silver;
}
~~~

<a name="nested-blocks"></a>
#### Nested blocks

You can *of course* nest your rule-sets. By default, the parent selector will be prepended to the nested selector (with whitespace — a descendant combinator), if the latter does not start with a different combinator:

~~~ lay
html > body {
    margin: 0
    background: white

    ul {
      list-style: none

      li {
        display: inline-block
      }
    }
  }
}
~~~

~~~ css
html > body {
  margin: 0;
  background: white;
}

html > body ul {
  list-style: none;
}

html > body ul li {
  display: inline-block;
}
~~~

If the nested selector *does* start with a combinator, it will be used to join its parent instead of the default descendant combinator:

~~~ lay
body {
  ul {
    list-style: none

    > li {
      + li {
        border-top: 1px dashed silver
      }
    }
  }
}
~~~

~~~ css
body ul {
  list-style: none;
}

body ul > li + li {
  border-top: 1px dashed silver;
}
~~~

The parent reference (`&`) can appear in a nested rule-set selector to indicate where the parent selector should be inserted. This is specially useful in case you want to add a complementary (attribute, id, class or pseudo) selector to its parent or prepend segments to it:

~~~~ lay
body {
  a {
    color: blue

    &:link {
      text-decoration: underline
    }
  }
}
~~~~

~~~~ css
body a {
  color: blue;
}

body a:link {
  text-decoration: underline;
}
~~~~

At-rules work in a similar fashion: you can nest them inside rule sets or other at-rules and they will be hoisted to the root block when converted to CSS. Related `@media` and `@supports` rules are by default flattened:

~~~ lay
.container {
  @media screen and (min-width: 200px) {
    min-width: 180px

    @media (max-width: 800px) {
      width: 100%
      p {
        font-size: larger
      }
    }
  }
}
~~~

~~~ css
@media screen and (min-width: 200px) {
  .container {
    min-width: 180px;
  }
}

@media screen and (min-width: 200px) and (max-width: 800px) {
  .container {
    width: 100%;
  }

  .container p {
    font-size: larger
  }
}
~~~


<a name="multiple-property-declarations"></a>
#### Multiple property declarations

Layla lets you set the same value on multiple properties at once, in a single statement. Just type a list of comma-separated names on the left side of a property declaration:

~~~ lay
img {
  margin, padding: 0

  &.avatar {
    width, height: 80px
  }
}
~~~

~~~ css
img {
  margin: 0;
  padding: 0;
}

img.avatar {
  width: 80px;
  height: 80px;
}
~~~

<a name="conditional-property-declarations"></a>
#### Conditional property declarations

Place a pipe character (`|`) right before the colon on a property declaration, and the property (or *properties*) will be set only if they have not been set before, or they're `null`:

~~~ lay
body {
  margin: 0
  border|: none
  margin, padding|: 20px
}
~~~

~~~ css
body {
  margin: 0;
  border: none;
  padding: 20px;
}
~~~

<a name="comments"></a>
#### Comments

Besides the regular CSS comments (`/* ... */`), line comments can also be written. They are started with a double slash `//` and include the rest of the line. They can appear at the beginning of the line or after something else:

~~~ lay
#comments {
  /**
   * This is a regular CSS comment
   */

  foo: /* an embedded comment */ bar

  // This is a line comment

  foo: bar // This is another line comment

  foo: rgba(  // Layla
         255, // is
         255, /* quite */, 255,
         .1,  // permissive
       )
  )
}
~~~

Note Layla will ignore all types of comments and thus won't output them:

~~~ css
#comments {
  foo: bar;
  foo: bar;
  foo: rgba(255, 255, 255, .1);
}
~~~

<a name="variables"></a>
#### Variables

Layla allows you to define compile-time variables and use them in expressions. You can create a variable with the `=` operator:

~~~~ lay
$size = 80px

img {
  width, height: $size
}
~~~~

~~~~ css
img {
  width: 80px;
  height: 80px;
}
~~~~

The `|=` operator performs the assignment only if the variable has not been defined before or if it's `null`:

~~~ lay
$size = 14px
$family = null

body {
  $size   |= 12px
  $family |= 'Helvetica'
  $weight |= normal

  font: $size $family $weight
}
~~~

~~~ css
body {
  font: 14px 'Helvetica' normal;
}
~~~


<a name="types"></a>
#### Built in types

Common types:

Type       | Synopsis                           | Examples
-----------|:-----------------------------------|:--------
`Boolean`  | A `true`/`false` value.          | `true`, `false`
`String`   | A sequence of characters, with our without quotes. | `"Lorem"`, `'ipsum'`, `dolor`
`Number`   | An number, with optional decimals and units. | `0`, `760px`, `33.33%`
`Color`    | An RGBA color | `#fff` `#3f2a2d`
`URL`      | An absolute or relative URL. | `url(http://disney.es)`, `url('//example.com')`
`RegExp`   | A regular expression you can use to match or split strings. | `/\d+/`, `/\$[a-z]{2,}/i`
`List`     | An ordered, numerically indexed collection of objects of any kind. | `1, 2, 3`, `"a" "b" "c"`
`Range`    | A stepped numeric interval, with optional units. | `1..10`, `0..10cm`
`Block`    | An ordered collection of properties and other `Block`s. | `{ foo: 0; bar: 1px }`
`Null`     | The `null` value, representing *the lack of a value*. | `null`

Full class tree:

<img src="https://raw.githubusercontent.com/kaime/layla/docs/src/doc/classes.png" alt="Layla class tree"/>

<a name="methods"></a>
#### Methods

Each type in Layla is fully loaded with a number of *methods* to operate, manipulate, transform or get information about [strings](#), [numbers](#), [colors](#), [URLs](#) or any of the other types.

Methods are invoked with the dot `.` operator followed by the method name and an optional list of arguments enclosed in parentheses (you can omit them if you are not passing any parameters).

~~~ lay
#methods {
  foo: 10.1782px.round(2)
  bar: "hello".upper-case
  baz: #fff.darken(15%)
}
~~~

~~~ css
#methods {
  foo: 10.18px;
  bar: "HELLO";
  baz: #d9d9d9;
}
~~~

*Predicate* methods, those which return boolean values, end by convention in a question mark (`?`).

~~~ lay
#predicate-methods {
  foo: (1,2).empty?
  bar: rgba(0,0,0,.99).opaque?
  baz: url(/search?q=foo).absolute?
  qux: "hi there!".starts-with?("bye")
}
~~~

~~~ css
#predicate-methods {
  foo: false;
  bar: false;
  baz: false;
  qux: false;
}
~~~

Here is a list of most methods. Methods defined on a type are inherited by its descendants, so a method defined by the `Indexed` class is also available on instances of `List` and `Range`. Being `Object` the root class, all its methods are available on any value, even `null`.

Type          | Methods
-------------:|:-------
`Object`      | `.and`, `.boolean`, `.contains?`, `.copy`, `.empty?`, `.enumerable?`, `.false?`, `.has`, `.hasnt`, `.in`, `.is`, `.isnt`, `.list`, `.not@`, `.null?`, `.number`, `.or`, `.quote`, `.quoted`, `.string`, `.true?`, `.unquote`, `.unquoted`, `.with`
`Enumerable`  | `.first`, `.last`, `.length`, `.max`, `.min`, `.random`
`Indexed`     | `.first-index`, `.index`, `.last-index`
`Number`      | `.abs`, `.acos`, `.asin`, `.atan`, `.ceil`, `.convert`, `.cos`, `.decimal?`, `.divisible-by?`, `.even?`, `.floor`, `.integer?`, `.mod`, `.negate`, `.negative`, `.negative?`, `.odd?`, `.positive`, `.positive?`, `.pow`, `.prime?`, `.pure`, `.pure?`, `.root`, `.round`, `sign`, `.sin`, `.sq`, `.sqrt`, `.tan`, `.unit?`, `.zero?`
`Color`       | `.alpha`, `.alpha=`, `.black`, `.black=`, `.blacken`, `.blackness`, `.blackness=`, `.blend`, `.blue`, `.blue=`, `.contrast`, `.cyan`, `.cyan=`, `.dark?`, `.darken`, `.desaturate`, `.gray`, `.gray?`, `.green`, `.green=`, `.grey`, `.grey?`, `.hue`, `.hue=`, `.invert`, `.light?`, `.lighten`, `.lightness`, `.lightness=`, `.luminance`, `.luminance?`, `.magenta`, `.magenta=`, `.opaque`, `.opaque?`, `.opposite`, `.red`, `.red=`, `.rotate`, `.safe`, `.safe?`, `.saturate`, `.saturation`, `.saturation=`, `.shade`, `.spin`, `.tint`, `.transparent`, `.transparent?`, `.whiten`, `.whiteness`, `.whiteness=`, `.yellow`, `.yellow=`
`String`      | `.append`, `.base64`, `.blank?`, `.characters`, `.empty?`, `.ends-with?`, `.length`, `.lines`, `.lower-case`, `.ltrim`, `.numeric?`, `.palindrome?`, `.quoted?`, `.replace`, `.repr`, `.reverse`, `.rtrim`, `.split`, `.starts-with?`, `.string`, `.trim`, `.unquoted?`, `.upper-case`, `.words`
`URL`         | `.absolute?`, `.domain`, `.fragment`, `.fragment=`, `.hash`, `.hash=`, `.host`, `.host=`, `.http`, `.http?`, `.https`, `.https?`, `.path`, `.port`, `.port=`, `.protocol`, `.protocol=`, `.query`, `.query=`, `.relative?`, `.scheme`, `.scheme=`, `.string`
`RegExp`      | `.global`, `.global?`, `.insensitive`, `.insensitive?`, `.multiline`, `.multiline?`, `.sensitive`, `.sensitive?`
`Collection`  | `.empty`, `.first`, `.last`, `.length`, `.pop`, `.push`, `.shift`, `.slice`, `.unique`, `.unique?`, `.unshift`
`List`        | `.commas`, `.flatten`, `.list`, `.spaces`
`Range`       | `.convert`, `.list`, `.pure`, `.pure?`, `.reverse`, `.reverse?`, `.step`, `.step=`, `.unit`, `.unit?`
`Block`       | `.has-property?`, `.properties`, `.rules`
`RuleSet`     | `.selector`
`AtRule`      | `.name`

<a name="operators"></a>
#### Operators

Operators are just like regular methods, with a more natural syntax and a [*precedence*](). You have binary (`2 + 2`, `false or true`) and unary (`-1`, `not true`) arithmetic, logical, comparison and other kinds of operators available in Layla. You can make math, concatenate, slice, split and match strings, adjust and mix colors, resolve URLs, manipulate lists and take boolean decisions:

~~~ lay
#some-operators {
   numbers: (2 + 6 - 3) * -1,
            (100 / 3)%,
            1200px * 2

   strings: "foo" + "bar",
            "foobar"::(0..3).upper-case,
            "Foo" ~ /foo|bar/i,
            "foo bar baz".split(/\s+/).join('-')

      urls: url('https://google.com/?q=foo') + '?utf8&q=bar'

     lists: [foo, bar] + baz

  booleans: black is black,
            5 > 2,
            1 <= 3,
            true and false,
            null or (black isnt white)
}
~~~

~~~ css
#some-operators {
  math: -5, 33.33%, 2400px;
  strings: "foobar", "FOO", true, 'foo-bar-baz';
  urls: url('https://google.com/search?utf&q=bar');
  lists: foo, bar, baz;
  booleans: true, true, true, false, true
}
~~~

Operators are implemented as methods and they are inherited by subclasses. For instance: the `is` operator of the `Object` class also works on any of the other types because they all inherit from `Object`.

Here is a list of all built-in operators.

Type     | Operators
--------:|:-------------------------------------------------------------
`Object` | `not Object` `Object is Object` `Object isnt Object` `Object and Object` `Object or Object`
`Number` | `+Number` `-Number` `Number + Number` `Number - Number` `Number * Number` `Number / Number` `Number > Number` `Number >= Number` `Number < Number` `Number <= Number` `Number * String`
`String` | `String + String` `String + URL` `String ~ RegExp` `String * Number` `String::Number` `String::List` `String::Range`
`Color`  | `Color + Color`
`URL`    | `URL + URL` `URL + String`
`RegExp` | `RegExp ~ String`
`List`   | `List + List` `List::Number` `List::List` `List::Range`
`Range`  | `Range + Range` `Range - Range` `Range / Number` `Range::Number` `Range::List`
`Block`  | `Block::Number` `Block::String`

<a name="interpolation"></a>
#### Interpolation

You can use interpolation (between `#{...}`) inside strings:

~~~ lay
$name = 'John'
$hi = "Hello, #{$name}"
~~~

Because interpolation is supported on any kind of string, including unquoted and raw strings, you can use them mostly everywhere, including selectors, at-rules, property names, URLs and on left side of an assignment:

~~~ lay
~~~

~~~ css
~~~

Inside `#{...}`, any expression is permitted:

~~~ lay
~~~

~~~ css
~~~

<a name="conditionals"></a>
#### Conditionals

Conditionals allow you to execute a block of code only if certain condition is met:

~~~ lay
$DEBUG = true

if $DEBUG {
  a::after {
    content: "[" attr(href) "]"
  }
}
~~~

~~~ css
a::after {
  content: "[" attr(href) "]";
}
~~~

Any number of additional `else if` and/or one `else` blocks can follow an `if` block:

~~~ lay
$DEBUG = 2

body {
  if $DEBUG is 1 {
    $background-color = silver
  } else if $DEBUG > 1 {
    $background-color = yellow
  } else {
    $background-color = white
  }

  background-color: $background-color
}
~~~

~~~ css
body {
  background-color: yellow;
}
~~~


<a name="loops"></a>
#### Loops

The most basic form of loop Layla supports is the `while` statement. It executes a block of code repeatedly *while* the condition is trueish:

~~~ lay
$columns = 3
$n = 1

while $n <= $columns {
  .col-#{$n} {
    width: ($n * 100 / $columns)%
  }
  $n = $n + 1
}
~~~

~~~ css
.col-1 {
  width: 33.33%;
}

.col-2 {
  width: 66.67%;
}

.col-3 {
  width: 100%;
}
~~~

The `for ... in` loop can be used to traverse certain types of values, like lists, ranges and blocks:

~~~ lay
$vendors = moz, webkit

for $n in 1..3 {
  for $vendor in $vendors {
    @-#{$vendor}-media screen and (min-width: 800px) {
      .col-#{$n} {
        width: ($n * 100 / 3)%
      }
    }
  }
}
~~~

~~~ css
@-moz-media screen and (min-width: 800px) {
  .col-1 {
    width: 33.33%;
  }

  .col-2 {
    width: 66.67%;
  }

  .col-3 {
    width: 100%;
  }
}

@-webkit-media screen and (min-width: 800px) {
  .col-1 {
    width: 33.33%;
  }

  .col-2 {
    width: 66.67%;
  }

  .col-3 {
    width: 100%;
  }
}
~~~

All these loops support *early exit* (`break`) and *resume* (`continue`), with an optional `depth` argument:

~~~~ lay
#even-numbers {
  $i = 0
  while true {
    if ($i.odd?) {
      continue
    }

    even: $i

    $i = $i + 1;

    if ($i > 10) {
      break
    }
  }
}
~~~~

~~~~ css
#even-numbers {
  even: 0;
  even: 2;
  even: 4;
  even: 6;
  even: 8;
  even: 10;
}
~~~~

<a name="functions"></a>
#### Functions

You can write your own functions and call them later. A function literal is an —optionally empty— list of comma-separated arguments, enclosed in parentheses —`()`— and followed by a block of code. An empty function with no arguments looks like this: `() {}`

Functions are always anonymous (they are normally assigned to something), closures (they inherit the context), and are *normally* bound to the block of the *caller* (the properties and rules they declare are added the caller block):

~~~~ lay
$default-border-radius: 4px

body {
  $rounded-corners = ($radius: $default-border-radius) {
    border-radius: $radius
  }

  button {
    $rounded-corners()
  }

  .avatar {
    $rounded-corners(8px)
  }
}
~~~~

~~~~ css
body button {
  border-radius: 4px;
}

body .avatar {
  border-radius: 8px;
}
~~~~

Instead of declaring properties and rules, a function can simply `return` a value:

~~~~ lay
$sum = ($a, $b: 1) {
  return $a + $b
}

body {
  five: $sum(2, 3)
  three: $sum(2)
}
~~~~

~~~~ css
body {
  five: 5;
  three: 3;
}
~~~~

As they inherit their context (and they're added to the context right after they are defined), they can be called recursively:

~~~ lay
$factorial-of = ($n) {
  if $n <= 1 {
    return 1
  } else {
    return $n * factorial-of($n - 1)
  }
}

.factorial-of {
  five: $factorial-of(5)
}
~~~

~~~ css
.factorial-of {
  five: 120;
}
~~~

<a name="custom-units"></a>
#### Custom units

Besides being able to convert between dimensions, you can define and use your own derived units; they will be converted to known CSS units as needed:

~~~ lay
1m = 100cm
1km = 1m
12col = 100%

.sidebar {
  width: 3col;
}

.main {
  width: 9col;
}

.grid {
  max-width: 1km;

  for $c in 1..6 {
    .col-#{$c} {
      width: ($c * 2)col
    }
  }
}
~~~

~~~ css
.sidebar {
  width: 25%;
}

.main {
  width: 75%;
}

.grid {
  max-width: 100000cm;
}

.grid .col-1 {
  width: 16.67%;
}

.grid .col-2 {
  width: 33.33%;
}

.grid .col-3 {
  width: 50%;
}

.grid .col-4 {
  width: 66.67%;
}

.grid .col-5 {
  width: 83.33%;
}

.grid .col-6 {
  width: 100%;
}
~~~

<a name="include"></a>
#### `include`

Unlike other similar tools, Layla won't do anything with your `@import` rules, but they will be output intact. Instead, you can use the `include` statement to load external files at compile-time, and much more.

Just pass one or more comma-separated filenames to the `include` statement:

~~~ lay
include 'reset.lay'
include 'widgets/button.lay',
        `widgets/checkbox.lay`,
        `widgets/radio.lay`
~~~

You can include external files not only at root level, but at any nested block. Context variables will be passed to the included script, and any variables it declares or changes will be applied to current context:

~~~ lay
~~~

Because blocks have their own context, you can include files inside a bare block to have a sort of way to "modularize" your files:

~~~ lay
$config = { include 'config.lay' }

body {
  background-color: $config::background-color
}
~~~

<a name="plugins"></a>
#### Plug-ins

Layla allows you to load plug-ins at runtime with the `use` statement. Plug-ins can define new functions, values or even extend the language.

~~~~ lay
use 'css/extras'

img.avatar {
  size: 90px
}
~~~~

~~~~ css
img.avatar {
  width: 90px;
  height: 90px;
}
~~~~

<a name="reflection"></a>
#### Reflection


# Installation

Layla can be run from the command line, on a browser, or included on your JavaScript application or on 3rd party libraries. You should the most addecuate installation mode for your needs.

## With NPM

> Use this method if you intend to use Layla from the command line or if you
> are going to include it as a JS library.

You'll need `node` installed. Type the following to install Layla globally (it may need `sudo`).

~~~ bash
$ npm install -g krokis/layla
~~~

After installing, you should be able to run the `layla` command and to `require("layla")`.

## With bower

> Use this method if you are already using bower in your project and
> you want to run Layla on the browser.

## Manual installation

> Use the following method if you have no other way to install Layla.





# Usage

## From the command-line

If you have installed Layla globally using NPM, you should have a `layla` command available. Enter `layla -h` to see available options:

~~~
Usage:
  layla [options] file...|< [>]

Options:
  -u, --use <plugin>      Use a plugin
  -o, --out-file <file>   Write compiled code to a file instead of printing it
  -i, --interactive       Start an interactive console
  -c, --colors            Use colors on the output
  -C, --no-colors         Don't use colors on the output
  -v, --version           Print out Layla version
  -h, --help              Show this help
~~~

Run `layla` followed by one or more file names and they all will be compiled into a single CSS document and output to `stdout`:

~~~
$ layla styles.lay > styles.css
~~~

Or use the `--out-file` option to write compiled CSS to a file instead of printing it to `stdout`:

~~~
$ layla base.lay forms.lay -o styles.css
~~~

If you don't provide at least one file, Layla will try to read from `stdin`:

~~~
$ cat styles.lay | layla > styles.css
~~~

Load one or more plugins before compilation with the `--use` option:

~~~ sh
$ layla --use "css/extras,npm" base.lay frontend.lay
~~~

The interactive mode allows you to play around with layla from the command line:

~~~ sh
$ layla --interactive
~~~

During an interactive session, the following control sequences are available:

- <kbd>ctrl</kbd> + <kbd>C</kbd> discards current line and start a new one.
- <kbd>ctrl</kbd> + <kbd>L</kbd> clears the screen.
- <kbd>ctrl</kbd> + <kbd>D</kbd> exits.

You can load plugins and import external `.lay` files before the prompt:

~~~ sh
$ layla -i -u npm -u css/extras mixins.lay
~~~

Use the `--colors` or `--no-colors` options to enable or disable ANSI colors on the output. By default, Layla will enable colors only in the interactive mode, if the console supports them.

~~~ sh
$ layla --interactive --no-colors
~~~

Type `layla --version` to print out installed Layla version.

~~~
$ layla version
0.0.0
~~~

## On the browser

You can include Layla on your page to compile your code directly on the client side. You can use this method to develop or play around with Layla, but **don't use it in production** unless you have a good reason:

- The browserified version of Layla is quite a big piece of JS to download.
- Client-side compilation can become *very* slow as your codebase grows.
- All imports are made *synchronously*, so the whole stylesheets can take a while to download if they are split in many files.
- Until the compilation is completed, an uncharming [FOUC](https://en.wikipedia.org/wiki/Flash_of_unstyled_content) will frequently appear.

Include the browserified bundle `layla.min.js` in your HTML:

~~~ html
<script src="/path/to/layla.min.js" type="text/javascript"></script>
~~~

Now you can write `<style>` tags with Layla code and `<link>` to external `.lay `files. Just make sure you set the `type` attribute to `text/lay`:

~~~ html
<html>
  <head>
    <script src="/path/to/layla.min.js"></script>
    <link rel="stylesheet/layla" type="text/lay" href="./config.lay">
    <style type="text/lay">
      $background |= white

      body {
        background-color: $background
      }
    </style>
  </head>
</html>
~~~

> Use the `stylesheet/layla` (or any other invalid) `rel` value in `<link>` tags to prevent some browsers to download the files twice.

All code will be compiled on the same context and added to the document with a standard `<style type="text/css>` element: in the snippet above, the `$background` variable could have been declared in the external `config.lay` file.

## With gulp

## With Grunt


# Credits

Layla was written between 2014 and 2017 by [Jaume Alemany](http://github.com/kaime) in [Valldemossa](https://www.google.es/maps/place/07170+Valldemossa,+Illes+Balears/@39.7110953,2.6188232,17z/data=!3m1!4b1!4m5!3m4!1s0x1297ee03ba8ac6ff:0x924852e78b96123e!8m2!3d39.7114523!4d2.6225698?hl=en).

It's written in [CoffeeScript](http://coffeescript.org/) and then compiled to JavaScript using [Cake](http://coffeescript.org/#cake) and the `coffee` compiler. The browser version is bundled with [Browserify](https://www.google.es/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwi7tPyZ-N_OAhVMORoKHZ9xDvwQFggeMAA&url=http%3A%2F%2Fbrowserify.org%2F&usg=AFQjCNEOwl4eO-QewxOy_9Np60mxDj97oQ&sig2=dDM8WzOOOubOGgP4FZhHog) and then minified with [UglifyJS](https://github.com/mishoo/UglifyJS).

Tests are run with [Mocha](https://mochajs.org/) and use [Chai](http://chaijs.com/), [Coffeelint](https://www.google.es/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=0ahUKEwi5_-D3-N_OAhVFtBoKHSyXATIQFggeMAA&url=http%3A%2F%2Fwww.coffeelint.org%2F&usg=AFQjCNEvy3BmlULSkx6EZNSSu7-RSdNKiQ&sig2=woAb3Updm7wx9XHq-1OfZw), [Selenium](https://github.com/SeleniumHQ/selenium), [PhantomJS](http://phantomjs.org/), [Express](http://expressjs.com/) and some other [npm packages](package.json).



