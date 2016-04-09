# 3rd party
parseURL    = require 'url'
Path        = require 'path'
Net         = require 'net'

Object      = require '../object'
Boolean     = require './boolean'
Null        = require './null'
String      = require './string'
Number      = require './number'

Error     = require '../error'
TypeError = require '../error/type'

class URL extends Object

  @property 'value',
    get: -> @toString()
    set: (value) ->
      value = value.trim()

      try
        parsed = parseURL.parse value, no, yes
      catch e
        throw e # TODO

      @scheme =
        if parsed.protocol?
          parsed.protocol[0...parsed.protocol.length - 1]
        else
          null
      @auth = if parsed.auth isnt '' then parsed.auth else null
      @host = if parsed.hostname isnt '' then parsed.hostname else null
      @port = if parsed.port isnt '' then parsed.port else null
      @path = if parsed.pathname isnt '' then parsed.pathname else null
      @query = parsed.query
      @fragment = if parsed.hash? and parsed.hash isnt ''
                    parsed.hash.substr 1
                  else
                    null
  constructor: (@value = '', @quote = null) ->

  clone: (value = @value, quote = @quote) ->
    super value, quote

  toString: ->
    str = ''

    str = "##{@fragment}#{str}" if @fragment isnt null
    str = "?#{@query}#{str}" if @query isnt null
    str = "#{@path}#{str}" if @path isnt null

    if @host
      str = ":#{@port}#{str}" if @port isnt null

      host = @host
      if ~ host.indexOf ':'
        if host[0] isnt '[' or host[host.length - 1] isnt ']'
          host = "[#{host}]"

      if @auth and @auth isnt ''
        host = "#{@auth}@#{host}"

      str = "//#{host}#{str}"
      str = "#{@scheme}:#{str}" if @scheme isnt null

    str

  toJSON: ->
    json = super
    json.value = @value
    json.quote = @quote
    json

  ###
  Resolves another URL or string with this as the base
  ###
  '.+': (other) ->
    if other instanceof URL or other instanceof String
      @clone (parseURL.resolve @value, other.value)
    else
      super

  '.scheme': -> if @scheme then new String @scheme, @quote or '"'

  '.scheme=': (sch) ->
    if sch instanceof Null
      @scheme = null
    else if sch instanceof String
      @scheme = sch.value
    else
      throw new Error "Bad URL scheme"

  '.protocol': @::['.scheme']

  '.protocol=': @::['.scheme=']

  '.absolute?': -> Boolean.new @scheme

  '.relative?': -> Boolean.new not @scheme

  '.http?': -> Boolean.new @scheme is 'http'

  '.http': ->
    http = @clone()
    http.scheme = 'http'
    http

  '.https?': -> Boolean.new @scheme is 'https'

  '.https': ->
    http = @clone()
    http.scheme = 'https'
    http

  '.auth': ->
    if @auth
      new String @auth, @quote or '"'
    else
      Null.null

  '.username': ->
    if @auth
      [username, _] = @auth.split ':'
      new String username, @quote or '"'
    else
      Null.null

  '.username=': (value) ->

  '.password': ->
    if @auth
      [_, password] = @auth.split ':'
      if password
        return new String password, @quote or '"'

    Null.null

  '.password=': (value) ->

  '.host': ->
    if @host
      new String @host, @quote or '"'
    else
      Null.null

  '.host=': (host) ->
    if host instanceof Null
      @host = null
    else if host instanceof String
      @host = host.value
    else
      throw new Error "Bad URL host"

  # Returns `true` if the host is a v4 IP
  '.ipv4?': -> Boolean.new Net.isIPv4 @host

  # Returns `true` if the host is a v6 IP
  '.ipv6?': -> Boolean.new Net.isIPv6 @host

  # Returns `true` if the host is an IP (v4 or v6)
  '.ip?': -> Boolean.new Net.isIP @host

  '.domain': ->
    domain = @host
    if domain?
      if domain.match /^www\./i
        domain = domain.substr 4
      new String domain, @quote or '"'
    else
      Null.null

  '.port': -> if @port then new String @port, @quote or '"'

  '.port=': (port) ->
    if port instanceof Null
      @port = null
      return

    if port instanceof String and port.isNumeric()
      port = port.toNumber()
    else if not (port instanceof Number)
      throw new TypeError """
        Cannot set URL port to non-numeric value: #{port.repr()}
        """

    p = port.value

    if p % 1 isnt 0
      throw new TypeError """
        Cannot set URL port to non integer number: #{port.reprValue()}
        """

    if 1 <= p <= 65535
      @port = p
    else
      throw new TypeError "Port number out of 1..65535 range: #{p}"

  '.path': -> if @path then new String @path, @quote or '"'

  '.path=': ->

  do =>
    pathInfo = (url, comp, etc...) ->
      if url.path?
        component = Path["#{comp}name"] url.path
        if component isnt ''
          return new String component, url.quote

      null

    ['dir', 'base', 'ext'].forEach (comp) =>
      @::[".#{comp}name"] = (etc...) ->
        Null.ifNull pathInfo @, comp, etc...

      @::[".#{comp}name="] = (etc...) ->

  '.filename': ->

  '.filename=': ->

  '.query': -> if @query then new String @query, @quote or '"'

  '.query=': (query) ->
    if query instanceof Null
      @query = null
    else if query instanceof String
      @query = query.value.trim()
    else
      throw new Error "Bad URL query"

  '.fragment': ->
    if @fragment isnt null then new String @fragment, @quote or '"'

  '.fragment=': (frag) ->
    if frag instanceof Null
      @fragment = null
    else if frag instanceof String
      @fragment = frag.value.trim()
    else
      throw new Error "Bad URL fragment"

  '.hash': @::['.fragment']

  '.hash=': @::['.fragment=']

  '.normalize': ->

  '.string': -> new String @toString(), @quote or '"'

  do ->
    supah = String::['.+']

    String::['.+'] = (other, etc...) ->
      if other instanceof URL
        other.clone parseURL.resolve @value, other.value
      else
        supah.call @, other, etc...

module.exports = URL
