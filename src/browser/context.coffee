CSSContext = require '../css/context'
XHRLoader  = require './xhr-loader'


###
###
class BrowserContext extends CSSContext

  constructor: ->
    super
    @use new XHRLoader


module.exports = BrowserContext
