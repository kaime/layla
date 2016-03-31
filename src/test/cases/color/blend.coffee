Phantom  = require 'phantom'

samples = require './samples.json'
modes = require './blend-modes.json'

page = null
browser = null

width = 400
height = 400

Phantom.create()
  .then (b) ->
    browser = b
    browser.createPage()

  .then (p) ->
    page = p
    html = '<html><body><canvas id="canvas"></canvas></body></html>'
    page.property 'content', html

  .then ->
    page.property 'viewportSize', width: width, height : width

  .then ->
    samples_json = JSON.stringify samples
    modes_json = JSON.stringify modes
    page.evaluateJavaScript "
      function() {
        window.samples = #{samples_json};
        window.modes = #{modes_json};
      }
      "
  .then ->
    page.evaluate ->
      canvas = document.getElementById 'canvas'
      ctx = canvas.getContext '2d'
      width = window.innerWidth
      height = window.innerHeight
      canvas.width = width
      canvas.height = height

      rgba = (hex) ->
        str = hex[1..]
        l = str.length
        alpha = 1

        switch l
          when 3, 4
            channels = [
              17 * parseInt str[0], 16
              17 * parseInt str[1], 16
              17 * parseInt str[2], 16
            ]

            if l > 3
              alpha = (17 * parseInt str[3], 16) / 255

          when 6, 8
            channels = [
              parseInt str[0..1], 16
              parseInt str[2..3], 16
              parseInt str[4..5], 16
            ]

            if l > 6
              alpha = (parseInt str[6..7], 16) / 255

        channels = channels.map (ch) -> Math.round ch
        alpha = (Math.round 100 * alpha) / 100

        if alpha < 1
          space = 'rgba'
          channels = channels.concat alpha
        else
          space = 'rgb'

        return "#{space}(#{channels.join ', '})"

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

      md = ''

      for mode in modes
        md += "- `#{mode}`\n"

        selector = "  color.blend[#{mode}] {\n"

        lay = "  ~~~ lay\n"
        css = "  ~~~ css\n"

        lay += selector
        css += selector

        index = 0

        for background in samples
          for source in samples
            index++
            roman = romanize index

            ctx.clearRect 0, 0, width, height

            ctx.beginPath()
            ctx.rect 0, 0, width, height

            ctx.globalCompositeOperation = 'source-over'

            ctx.fillStyle = "white"
            ctx.fill()

            ctx.fillStyle = rgba background
            ctx.fill()

            ctx.globalCompositeOperation =
              if mode is 'normal' then 'source-over' else mode
            ctx.fillStyle = rgba source
            ctx.fill()

            result = (ctx.getImageData width / 2, height / 2, 1, 1).data

            hex = '#'
            for i in [0..3]
              break if (i > 2) and (result[i] is 255)
              h = result[i].toString 16
              if h.length < 2
                h = "0" + h
              hex += h

            lay += "    #{roman}: #{source}.blend(#{background}.blend(#fff),\
                   '#{mode}')\n"
            css += "    #{roman}: #{hex};\n"

        lay += "  }\n  ~~~\n"
        css += "  }\n  ~~~\n"

        md += "\n" + lay + "\n" + css + "\n"

      return md

  .then (md) ->
    console.log md
    page.close()
    browser.exit()
  .catch (err) ->
    console.log err
    browser.exit()
