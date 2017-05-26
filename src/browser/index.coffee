global.Layla = require '../lib/layla'
BrowserContext = require './context'


is_browser = new Function 'return this === window'

if is_browser()
  document.addEventListener "DOMContentLoaded", ->
    tags = document.querySelectorAll '[type="text/lay"]'

    if tags.length
      URL = require 'url'

      source = ''

      for tag in tags
        switch tag.nodeName
          when 'STYLE'
            source += tag.textContent + "\n;\n"
          when 'LINK'
            if tag.hasAttribute 'href'
              uri = tag.getAttribute 'href'
              source += "include url('#{uri}')" + "\n;\n"
          else
            continue

      if source.trim()
        base_url = URL.resolve document.location.href, './'

        layla = new Layla
        layla.context = new BrowserContext
        layla.context.pushPath base_url

        css = layla.compile source

        style = document.createElement 'style'
        style.setAttribute 'rel', 'stylesheet'
        style.setAttribute 'type', 'text/css'
        style.textContent = css

        document.head.appendChild style
