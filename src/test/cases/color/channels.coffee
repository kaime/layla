Color = require 'color' # In you we trust

channels = require './channels.json'
samples = (require './samples.json').map (sample) -> Color(sample)

ROMANS =
  m:  1000
  cm:  900
  d:   500
  cd:  400
  c:   100
  xc:   90
  l:    50
  xl:   40
  x:    10
  ix:    9
  v:     5
  iv:    4
  i:     1

romanize = (n) ->
  if 0 < n <= 3000
    roman = ''

    for i of ROMANS
      while n >= ROMANS[i]
        roman += i
        n -= ROMANS[i]

    roman
  else
    throw new Error

indent = (str) -> str.replace /^(?!\s*$)/mg, '  '

fence = (lang, str) ->
  if str.trim() isnt ''
    "~~~ #{lang}\n" + str + "~~~\n\n"
  else
    ''

rule_set = (method, body) ->
  if body.trim() isnt ''
    "color.#{method} {\n" + (indent body) + "}\n"
  else
    ''

normalize_value = (channel, value) ->
  norm = parseFloat value

  if value[value.length - 1] is '%'
    switch channel
      when 'hue'
        norm = 360 * norm / 100
      when 'red', 'green', 'blue'
        norm = 255 * norm / 100
      when 'alpha'
        norm /= 100

  return norm

expected_css = (channel, value) ->
  unit = ''

  if value > 0
    switch channel
      when 'hue'
        unit = 'deg'
      when 'red', 'green', 'blue', 'alpha'
        unit = ''
      else
        unit = '%'

  "#{value}#{unit}"

hex_string = (color) ->
  str = color.hexString().toLowerCase()
  if color.alpha() < 1
    a = Math.round(color.alpha() * 255).toString 16

    if a.length < 2
      a += a
    str += a

  return str

md = ""

for channel in channels
  # Getter
  md += "#### `#{channel}`\n\n"
  md += "- Returns the `#{channel}` channel of the color\n\n"

  lay = css = ''

  round = if channel is 'alpha' then '.round(2)' else '.round'

  for sample, i in samples
    actual = expected_css channel, sample[channel]()
    r = romanize i + 1
    lay += "#{r}: #{hex_string sample}.#{channel}#{round}"
    lay += "\n"

    css += "#{r}: #{actual};\n"

  md += indent (
    (fence 'lay', rule_set channel, lay) +
    (fence 'css', rule_set channel, css)
  )

  # Setter
  md += "#### `#{channel}=`\n\n"
  md += "- Adjusts the `#{channel}` channel of the color\n\n"

  switch channel
    when 'red', 'green', 'blue'
      values = ['0', '127.50', '255', '100%', '33.33%']
    when 'cyan', 'magenta', 'yellow', 'black', \
         'blackness', 'whiteness', 'saturation', 'lightness', 'value'
      values = ['0', '0%', '17.98%', '100%']
    when 'alpha'
      values = ['0', '.1', '99%', '100%', '1']
    when 'hue'
      values = ['0', '90', '360', '736']
    else
      continue

  lay = css = ''

  p = 0

  for sample, i in samples
    copy = sample.clone()

    lay += "\n" if i > 0

    var_name = romanize i + 1
    lay += "$#{var_name} = #{hex_string sample}\n"

    for value, j in values
      p++

      lay += "\n" if j > 0

      prop_name = romanize p

      lay += "$#{var_name}.#{channel} = #{value}\n"
      lay += "#{prop_name}: $#{var_name}.#{channel}#{round}\n"

      copy[channel](normalize_value channel, value)
      actual = copy[channel]()

      css += "#{prop_name}: #{expected_css channel, actual};\n"

  md += indent (
    (fence 'lay', rule_set channel, lay) +
    (fence 'css', rule_set channel, css)
  )

console.log md
