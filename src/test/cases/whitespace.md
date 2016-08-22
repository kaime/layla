# Whitespace

## Significance

### In rule-sets

#### Before selector

- Whitespace is not required

  ~~~ lay
  .whitespace {
    color: white
  };.whitespace  { color: white };#whitespace {color: white };
  #whitespace { color: white }
  [whitespace] { color: white } [whitespace] { color: white } * { color: white };
  * { color: white };
  whitespace { color: white };;whitespace { color: white };
  ~~~

  ~~~ css
  .whitespace {
    color: white;
  }

  .whitespace {
    color: white;
  }

  #whitespace {
    color: white;
  }

  #whitespace {
    color: white;
  }

  [whitespace] {
    color: white;
  }

  [whitespace] {
    color: white;
  }

  * {
    color: white;
  }

  * {
    color: white;
  }

  whitespace {
    color: white;
  }

  whitespace {
    color: white;
  }
  ~~~

- All whitespace is ignored

  ~~~ lay
     .whitespace {
    color: white
  };   .whitespace  { color: white };

      #whitespace {color: white }; #whitespace { color: white };	 [whitespace] { color: white }
  ~~~

  ~~~ css
  .whitespace {
    color: white;
  }

  .whitespace {
    color: white;
  }

  #whitespace {
    color: white;
  }

  #whitespace {
    color: white;
  }

  [whitespace] {
    color: white;
  }
  ~~~

#### In selector

##### Around combinators

- Whitespace is not required

  ~~~ lay
  body+foo bar~baz>qux { foo: nope }
  body +  foo    bar ~ baz>   qux { foo: nope }
  body+  foo    bar~  baz   >qux { foo: nope }
  ~~~

  ~~~ css
  body + foo bar ~ baz > qux {
    foo: nope;
  }

  body + foo bar ~ baz > qux {
    foo: nope;
  }

  body + foo bar ~ baz > qux {
    foo: nope;
  }
  ~~~

- Horizontal whitespace is ignored

  ~~~ lay
  body      +          foo                     bar     ~      baz         >          qux { foo: nope }
  ~~~

  ~~~ css
  body + foo bar ~ baz > qux {
    foo: nope;
  }
  ~~~

##### In attribute selectors

###### Before attribute name

- Whitespace is not required

  ~~~ lay
  [foo] [foo=bar] [foo|=bar] [foo*=bar] [foo~=bar] [foo^=bar] [foo$=bar] {
    its: alright
  }
  [foo] [foo='bar'] [foo|='bar'] [foo*='bar'] [foo~='bar'] [foo^='bar'] [foo$='bar'] {
    its: alright
  }
  [foo] [foo="bar"] [foo|="bar"] [foo*="bar"] [foo~="bar"] [foo^="bar"] [foo$="bar"] {
    its: alright
  }
  ~~~

  ~~~ css
  [foo] [foo=bar] [foo|=bar] [foo*=bar] [foo~=bar] [foo^=bar] [foo$=bar] {
    its: alright;
  }

  [foo] [foo="bar"] [foo|="bar"] [foo*="bar"] [foo~="bar"] [foo^="bar"] [foo$="bar"] {
    its: alright;
  }

  [foo] [foo="bar"] [foo|="bar"] [foo*="bar"] [foo~="bar"] [foo^="bar"] [foo$="bar"] {
    its: alright;
  }
  ~~~

- Horizontal whitespace is ignored

  ~~~ lay
  [ foo] [  foo=bar] [  foo|=bar] [ foo*=bar] [ 	foo~=bar] [	 foo^=bar] [ foo$=bar] {
    its: alright
  }
  ~~~

  ~~~ css
  [foo] [foo=bar] [foo|=bar] [foo*=bar] [foo~=bar] [foo^=bar] [foo$=bar] {
    its: alright;
  }
  ~~~

###### Before operator

- Whitespace is not required

  ~~~ lay
  [foo] [foo=bar] [foo|=bar] [foo*=bar] [foo~=bar] [foo^=bar] [foo$=bar] {
    its: alright
  }
  ~~~

  ~~~ css
  [foo] [foo=bar] [foo|=bar] [foo*=bar] [foo~=bar] [foo^=bar] [foo$=bar] {
    its: alright;
  }
  ~~~

- Horizontal whitespace is ignored

  ~~~ lay
  [foo] [foo =bar] [foo  |=bar] [foo 	*=bar] [foo	~=bar] [foo ^=bar] [foo$=bar] {
    its: alright
  }
  ~~~

  ~~~ css
  [foo] [foo=bar] [foo|=bar] [foo*=bar] [foo~=bar] [foo^=bar] [foo$=bar] {
    its: alright;
  }
  ~~~

###### Before closing brace

- Horizontal whitespace is ignored

  ~~~ lay
  [foo   ] [foo=bar  ] [foo|=bar  i   ] [foo*=bar  ] [foo~=bar  ] [foo^=bar  ] [foo$=bar  i   ] {
    its: alright
  }
  [foo   ] [foo='bar'  ] [foo|='bar'  ] [foo*='bar'  ] [foo~='bar'  i   ] [foo^='bar'  ] [foo$='bar'] {
    its: alright
  }
  [foo   ] [foo="bar"  i] [foo|="bar"  ] [foo*="bar"  i   ] [foo~="bar"  ] [foo^="bar"  ] [foo$="bar"] {
    its: alright
  }
  ~~~

  ~~~ css
  [foo] [foo=bar] [foo|=bar i] [foo*=bar] [foo~=bar] [foo^=bar] [foo$=bar i] {
    its: alright;
  }

  [foo] [foo="bar"] [foo|="bar"] [foo*="bar"] [foo~="bar" i] [foo^="bar"] [foo$="bar"] {
    its: alright;
  }

  [foo] [foo="bar" i] [foo|="bar"] [foo*="bar" i] [foo~="bar"] [foo^="bar"] [foo$="bar"] {
    its: alright;
  }
  ~~~


#### Before flag

- Whitespace is not required

  ~~~ lay
  [foo] [foo=bari]  {
    its: alright;
  }
  ~~~

  ~~~ css
  [foo] [foo=bari] {
    its: alright;
  }
  ~~~

  ~~~ lay
  [foo] [foo="bar"i]  {
    its: alright;
  }
  ~~~

  ~~~ css
  [foo] [foo="bar" i] {
    its: alright;
  }
  ~~~

- Extra horizontal whitespace is ignored

  ~~~ lay
  [foo] [foo=bar        i]  {
    its: alright;
  }

  [foo] [foo="bar"         i]  {
    its: alright;
  }
  ~~~

  ~~~ css
  [foo] [foo=bar i] {
    its: alright;
  }

  [foo] [foo="bar" i] {
    its: alright;
  }
  ~~~

##### In pseudo-selectors

###### After colon

- Whitespace is not allowed

  ~~~ lay
  body ul > li a: hover {
    border: 1px solid red
  }
  ~~~

  ~~~ SyntaxError
  ~~~

  ~~~ lay
  body ul > li a:: before {
    border: 1px solid green
  }
  ~~~

  ~~~ SyntaxError
  ~~~

###### Before opening parenthesis

- Whitespace is not allowed

  ~~~ lay
  body ul > li a:not (.ext) {
    border: 1px solid red
  }
  ~~~

  ~~~ SyntaxError
  ~~~

###### Around arguments

- Whitespace is not required

  ~~~ lay
  body ul > li:nth-child(-2n+1) {
    border: 1px solid red
  }

  body ul > li a:not(.external,.ext){
    border: 1px solid red
  }
  ~~~

  ~~~ css
  body ul > li:nth-child(-2n + 1) {
    border: 1px solid red;
  }

  body ul > li a:not(.external, .ext) {
    border: 1px solid red;
  }
  ~~~

- Horizontal whitespace is ignored

  ~~~ lay
  body ul > li:nth-child(   -2n  +   1   ) {
    border: 1px solid red
  }

  body ul > li a:not(   .external   ,    .ext , strong   >  a){
    border: 1px solid red
  }
  ~~~

  ~~~ css
  body ul > li:nth-child(-2n + 1) {
    border: 1px solid red;
  }

  body ul > li a:not(.external, .ext, strong > a) {
    border: 1px solid red;
  }
  ~~~

### After selector

- Whitespace is not required

  ~~~ lay
  .class{color: white}
  #id{color: white}
  :pseudo(){color: white}
  ~~~

  ~~~ css
  .class {
    color: white;
  }

  #id {
    color: white;
  }

  :pseudo() {
    color: white;
  }
  ~~~

- All whitespace is ignored

  ~~~ lay
  .whitespace{color: white}
  .whitespace  { color: white }
  ~~~

  ~~~ css
  .whitespace {
    color: white;
  }

  .whitespace {
    color: white;
  }
  ~~~

## In at-rules

### Before at-symbol

- Whitespace is not required

  ~~~ lay
  @media screen { body { background: silver}};;@media print { body { background: white}}@media screen { body { max-width: 800px}}
  ~~~

  ~~~ css
  @media screen {
    body {
      background: silver;
    }
  }

  @media print {
    body {
      background: white;
    }
  }

  @media screen {
    body {
      max-width: 800px;
    }
  }
  ~~~

- All whitespace is ignored

  ~~~ lay
      @media screen { body { background: silver}}



  @media print { body { background: white}}     @media screen { body { max-width: 800px}}
  ~~~

  ~~~ css
  @media screen {
    body {
      background: silver;
    }
  }

  @media print {
    body {
      background: white;
    }
  }

  @media screen {
    body {
      max-width: 800px;
    }
  }
  ~~~

### Around arguments

- Whitespace is not required

- Horizontal whitespace is ignored

  ~~~ lay
  @media    screen    and  (max-width: 200px)   not    print    {
    body {
      background: silver
    }
  }
  ~~~

  ~~~ css
  @media screen and (max-width: 200px) not print {
    body {
      background: silver;
    }
  }
  ~~~

### After an opening parenthesis

- Horizontal whitespace is ignored

  ~~~ lay
  @media    screen    and  (    max-width: 200px)   not    print    {
    body {
      background: silver
    }
  }
  ~~~

  ~~~ css
  @media screen and (max-width: 200px) not print {
    body {
      background: silver;
    }
  }
  ~~~

### Before a closing parenthesis

- Horizontal whitespace is ignored

  ~~~ lay
  @media    screen    and  (max-width: 200px      )   not    print    {
    body {
      background: silver
    }
  }
  ~~~

  ~~~ css
  @media screen and (max-width: 200px) not print {
    body {
      background: silver;
    }
  }
  ~~~

### After a property name

- Whitespace is not required

  ~~~ lay
  @media    screen    and  (max-width: 200px)  {
    body {
      background: silver
    }
  }
  ~~~

  ~~~ css
  @media screen and (max-width: 200px) {
    body {
      background: silver;
    }
  }
  ~~~

- Horizontal whitespace is ignored

  ~~~ lay
  @media    screen    and  (max-width     :200px)  {
    body {
      background: silver
    }
  }
  ~~~

  ~~~ css
  @media screen and (max-width: 200px) {
    body {
      background: silver;
    }
  }
  ~~~

### Before a property value

- Whitespace is not required

  ~~~ lay
  @media    screen    and  (min-width:200px)and (max-width     :1200px)  {
    body {
      background: white
    }
  }
  ~~~

  ~~~ css
  @media screen and (min-width: 200px) and (max-width: 1200px) {
    body {
      background: white;
    }
  }
  ~~~

- Horizontal whitespace is ignored

  ~~~ lay
  @media    screen    and  (min-width:     200px)and (max-width     :     1200px)  {
    body {
      background: white
    }
  }
  ~~~

  ~~~ css
  @media screen and (min-width: 200px) and (max-width: 1200px) {
    body {
      background: white;
    }
  }
  ~~~

## In expressions

### After an opening parenthesis

- Whitespace is not required

  ~~~ lay
  expression::whitespace {
    $foo = 1
    i: ($foo + 1)
    ii: (2+3)
    iii: (-$foo + 1)
    iv: (-2+3)
    v: ((2,3))
    vi: (/.*/)
    vii: (url(http://example.org/home))
    viii: (null),(true),(false)
    ix: (1..2), (-1..1)
    x: (#fff)
  }
  ~~~

  ~~~ css
  expression::whitespace {
    i: 2;
    ii: 5;
    iii: 0;
    iv: 1;
    v: 2, 3;
    vi: regexp(".*");
    vii: url("http://example.org/home");
    viii: null, true, false;
    ix: 1 2, -1 0 1;
    x: #ffffff;
  }
  ~~~

- All whitespace is ignored

  ~~~ lay
  expression::whitespace {
    $foo = 1
    i: (  $foo + 1)
    ii: (

      2+3)
    iii: (  -$foo + 1)
    iv: ( -2+3)
    v: (   (

       2,3))
    vi: (   /.*/)
    vii: (
      url(http://example.org/home))
    viii: (   null),(   true),(  false)
    ix: (   1..2), (   -1..1)
    x: (   #fff)
  }
  ~~~

  ~~~ css
  expression::whitespace {
    i: 2;
    ii: 5;
    iii: 0;
    iv: 1;
    v: 2, 3;
    vi: regexp(".*");
    vii: url("http://example.org/home");
    viii: null, true, false;
    ix: 1 2, -1 0 1;
    x: #ffffff;
  }
  ~~~

### Before a closing parenthesis

- All whitespace is ignored

  ~~~ lay
  expression::whitespace {
    $foo = 1
    i: ($foo + 1   )
    ii: (2+3
      )
    iii: (-$foo + 1   )
    iv: (-2+3  )
    v: ((2,3

      )

    )
    vi: (/.*/

      )
    vii: (url(http://example.org/home)
    )
    viii: (null
      ),(true),(false  )
    ix: (1..2  ), (-1..1
      )
    x: (#fff

      )
  }
  ~~~

  ~~~ css
  expression::whitespace {
    i: 2;
    ii: 5;
    iii: 0;
    iv: 1;
    v: 2, 3;
    vi: regexp(".*");
    vii: url("http://example.org/home");
    viii: null, true, false;
    ix: 1 2, -1 0 1;
    x: #ffffff;
  }
  ~~~

### Around binary operators

- Around `+`, `-`, `/` and `*`

  + Whitespace is not required

    ~~~ lay
    whitespace::binary-operators {
      i: -(1+7)-3/2*+15px
    }
    ~~~

    ~~~ css
    whitespace::binary-operators {
      i: -30.5px;
    }
    ~~~

  + All whitespace is ignored

    ~~~ lay
    whitespace::binary-operators {
      i: - (1 +
        7)   -
        3/
        2   *    + 15px
    }
    ~~~

    ~~~ css
    whitespace::binary-operators {
      i: -30.5px;
    }
    ~~~

- Around `>`, `>=`, `<`, `<=` and `~`

  + Whitespace is not required

    ~~~ lay
    whitespace::binary-operators {
      i: 1>2, (1)>(2)
      ii: 2>=1, (2)>=(1)
      iii: 2<=1, (2)<=(1)
      iv: 2<1, (2)<(1)
      v: "foo"~/[a-z]+/, ("foo")~(/[a-z]+/)
    }
    ~~~

    ~~~ css
    whitespace::binary-operators {
      i: false, false;
      ii: true, true;
      iii: false, false;
      iv: false, false;
      v: "foo", "foo";
    }
    ~~~

  + All whitespace is ignored

    ~~~ lay
    whitespace::binary-operators {
      i: 1  >   2
      ii: 2>=
      1
      iii: 2<=
      1
      iv: 2              <
          (1)
    }
    ~~~

    ~~~ css
    whitespace::binary-operators {
      i: false;
      ii: true;
      iii: false;
      iv: false;
    }
    ~~~

- Around `=`, `|=`

  + Whitespace is not required

    ~~~ lay
    $foo=41
    $baz=$bar=$foo+1

    whitespace::assignment-operators {
      i: $foo
      ii: $bar
      iii: $baz
      iv: $foo|=($baz|=$bar|=45)
      v: $bar
      vi: $baz
    }
    ~~~

    ~~~ css
    whitespace::assignment-operators {
      i: 41;
      ii: 42;
      iii: 42;
      iv: 41;
      v: 42;
      vi: 42;
    }
    ~~~

  + All whitespace is ignored

    ~~~ lay
    $foo    =41
    $baz=
    $bar    =
      ($foo+1)

    whitespace::assignment-operators {
      i: $foo
      ii: $bar
      iii: $baz
      iv: $foo|=
      ($baz |=
           $bar|=    45
      )
      v: $bar
      vi: $baz
    }
    ~~~

    ~~~ css
    whitespace::assignment-operators {
      i: 41;
      ii: 42;
      iii: 42;
      iv: 41;
      v: 42;
      vi: 42;
    }
    ~~~

- Around `..`

  + Whitespace is not required

    ~~~ lay
    whitespace::range-operator {
      i: 1..5
      ii: (5)..(1px)
    }
    ~~~

    ~~~ css
    whitespace::range-operator {
      i: 1 2 3 4 5;
      ii: 5px 4px 3px 2px 1px;
    }
    ~~~

    ~~~ lay
    whitespace::range-operator {
      i: 1  ..  5
      ii: (5)  ..
      (1px)
    }
    ~~~

    ~~~ css
    whitespace::range-operator {
      i: 1 2 3 4 5;
      ii: 5px 4px 3px 2px 1px;
    }
    ~~~

  + All whitespace is ignored

- Around `,`

  + Whitespace is not required

    ~~~ lay
    whitespace::comma-operator {
      $two = 2
      i: 1,$two,3
      ii: (1),($two),2+1
    }
    ~~~

    ~~~ css
    whitespace::comma-operator {
      i: 1, 2, 3;
      ii: 1, 2, 3;
    }
    ~~~

  + All whitespace is ignored

    ~~~ lay
    whitespace::comma-operator {
      $two = 2
      i: 1,     $two,
      3
      ii: (1),
      ($two),
          2+1
    }
    ~~~

    ~~~ css
    whitespace::comma-operator {
      i: 1, 2, 3;
      ii: 1, 2, 3;
    }
    ~~~

- Around `.` and `::`

  + Whitespace is not required

    ~~~ lay
    whitespace::subscript {
      i: 10.17.round
      ii: (10.17).("round")
      iii: (10.17).round
      iv: (&)::i
      v: &::("i")
    }
    ~~~

    ~~~ css
    whitespace::subscript {
      i: 10;
      ii: 10;
      iii: 10;
      iv: 10;
      v: 10;
    }
    ~~~

  + All whitespace is ignored

    ~~~ lay
    whitespace::subscript {
      i: 10.17. round
      ii: 10.17 .round
      iii: 10.17 . round
      iv: 10.17.
      round
      v: &:: i
      vi: &  ::i
      vii: &  ::  i
      viii: &  ::
        i
    }
    ~~~

    ~~~ css
    whitespace::subscript {
      i: 10;
      ii: 10;
      iii: 10;
      iv: 10;
      v: 10;
      vi: 10;
      vii: 10;
      viii: 10;
    }
    ~~~

### Around unary operators

- Whitespace is not required

### In blocks

#### After opening bracket

- Whitespace is not required

- All whitespace is ignored

#### Before closing bracket

- Whitespace is not required

- All whitespace is ignored

### In property declarations

#### Before property name

- Whitespace is not required

- All whitespace is ignored

#### After property name

- Whitespace is not required

- Horizontal whitespace is ignored

- Line breaks are not allowed

#### After colon

- Whitespace is not required

- All whitespace is ignored

### In control structures

#### Before condition

- Horizontal whitespace is ignored

### In imports

### In directives

### In functions

### In method calls

#### Before parentheses

- Whitespace is not allowed

#### After parentheses

- Whitespace is not required

- All whitespace is ignored

#### Before commas

- Whitespace is not required

- Horizontal whitespace is ignored

#### After commas

- Whitespace is not required

- All whitespace is ignored

### In URL literals

#### Before opening parenthesis

#### After opening parenthesis

- Whitespace is not required

- All whitespace is ignored

#### Before closing parenthesis

- Whitespace is not required

- All whitespace is ignored

### In numbers

#### Around decimal point

- Whitespace is not allowed

#### Between value and unit

- Whitespace is not allowed

## Line endings

- Can be of any type

  + LF

    ~~~ lay
    import 'whitespace/lf.lay'
    ~~~

    ~~~ css
    @lf {
      is: ok;
    }
    ~~~

  + CR

    ~~~ lay
    import 'whitespace/cr.lay'
    ~~~

    ~~~ css
    @cr {
      is: ok;
    }
    ~~~

  + CRLF

    ~~~ lay
    import 'whitespace/crlf.lay'
    ~~~

    ~~~ css
    @crlf {
      is: ok;
    }
    ~~~

- End valid statements

## UT-8 BOM's

- Are ignored

  ~~~ lay
  import 'whitespace/bom.lay'
  ~~~

  ~~~ css
  @bom {
    is: ok;
  }
  ~~~
