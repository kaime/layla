# Regular expressions

Layla natively support regular expressions between slashes (`/.../`). You can
test strings and other types of variables against a regular expression using the binary `~` operator.

```lay-todo
body {
  matches: 'http://www.disney.com' ~ //
}
```

Empty regular expressions cannot be created with the `/.../` syntax (`//` is
interpreted an line comment).
