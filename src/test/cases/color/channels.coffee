Color = require 'color' # In you we trust

channels = require './channels.json'
samples = (require './samples.json').map (sample) -> Color(sample)

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

expected_css = (channel, value) ->
  if value > 0
    unit = '%'

    switch channel
      when 'hue'
        unit = 'deg'
      when 'red', 'green', 'blue', 'alpha'
        unit = ''
  else
    unit = ''

  "#{value}#{unit}"

md = ''

for channel in channels
  # Getter
  md += "### `#{channel}`\n\n"
  md += "- Returns the `#{channel}` channel of the color\n\n"

  lay = css = ''

  for sample in samples
    actual = expected_css channel, sample[channel]()
    lay += "color: #{sample.hexString()}.#{channel}.round\n"
    css += "color: #{actual};\n"

  md += indent (
    (fence 'lay', rule_set channel, lay) +
    (fence 'css', rule_set channel, css)
  )

  # ?
  md += "### `#{channel}?`\n\n"
  md += "- Returns `true` if the color has any #{channel}\
         (ie: its `#{channel}` value is > 0)\n\n"

  lay = css = ''

  md += indent (
    (fence 'lay', rule_set channel, lay) +
    (fence 'css', rule_set channel, css)
  )

  # Setter
  md += "### `#{channel}=`\n\n"
  md += "- Adjusts the `#{channel}` channel of the color\n\n"

  switch channel
    when 'red', 'green', 'blue'
      values = ['0', '127.50', '255', '100%', '33.33%']
    when 'cyan', 'magenta', 'yellow', 'black', 'blackness', 'whiteness'
      values = ['0', '0%', '17.98%', '100%']
    when 'alpha'
      values = ['0', '.1', '99%', '100%', '1']
    else
      continue

  lay = css = ''

  for sample, i in samples

    name = "$color_#{i}"
    lay += "#{name} = #{sample.hexString()}\n"

    for value in values
      lay += "#{name}.#{channel} = #{value}\n"
      lay += "#{channel}: #{name}.#{channel};\n"
      actual = expected_css channel, sample[channel]()
      css += "#{channel}: #{expected_css channel, actual};\n"

  md += indent (
    (fence 'lay', rule_set channel, lay) +
    (fence 'css', rule_set channel, css)
  )

console.log md
