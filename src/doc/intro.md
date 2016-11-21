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
