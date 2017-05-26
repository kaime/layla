URL          = require 'url'

Loader       = require '../lib/loader'
IncludeError = require '../lib/error/include'


###
###
class XHRLoader extends Loader

  canLoad: (uri, context) ->
    url = URL.parse uri
    url.protocol in ['http:', 'https:']

  load: (uri, context) ->
    xhr = new XMLHttpRequest
    xhr.addEventListener 'load', ->
    xhr.open 'GET', uri, no
    xhr.send()

    if xhr.status == 200
      return xhr.responseText

    throw new IncludeError "Could not load URL `#{uri}`"


module.exports = XHRLoader
