# Strings

You can use single (`'`) and double (`"`") quotes to define a string literal.

``` lay
comic-sans = 'Comic Sans'
helvetica = 'Helvetica'

body {
  font-family: helvetica, comic-sans
}
```

``` css
body {
  font-family: "Helvetica", "Comic Sans";
}
```

The following escape characters can be represented with backslash notation:

* `\n`: Newline
* `\r`: Carriage return
* `\t`: Tab

Also:
- Newline escape.
- Unicode escapes
