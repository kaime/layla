###
Type          | Methods
-------------:|:-------
`Object`      | `equals?` `true?` `false?` `empty?` `null?` `string` `quoted` `unquoted` `number` `boolean` `copy` `repr`
`Enumerable`  | `length` `current` `key` `first` `last` `random` `first-key` `last-key` `random-key`
`Indexed`     | `index` `first-index` `last-index` `random-index`
###

Objects = [
  require '../lib/object'
  require '../lib/object/enumerable'
  require '../lib/object/indexed'
  require '../lib/object/number'
  require '../lib/object/color'
  require '../lib/object/string'
  require '../lib/object/url'
  require '../lib/object/regexp'
  require '../lib/object/collection'
  require '../lib/object/list'
  require '../lib/object/range'
  require '../lib/object/block'
  require '../lib/object/rule-set'
  require '../lib/object/at-rule'
]

width = 0

for Obj in Objects
  width = Math.max width, Obj.name.length

width += 3

pad = (str) ->
  str + ' '.repeat(Math.max(1, width - str.length))

md = ''

md += pad('Type', ) + ' | Methods\n'
md += '-'.repeat(width) +  ':|:-------\n'

for Obj in Objects
  methods = global.Object.getOwnPropertyNames Obj.prototype
  methods = methods.filter (method) -> /\.[a-z]/i.exec method

  if methods.length
    md += pad('`' + Obj.name + '`')
    md += ' | '

    methods = methods.sort()
    methods = methods.map (method) -> "`#{method}`"

    md += methods.join ', '
    md += '\n'

console.log md
