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

  # data:[<mediatype>][;base64],<data>

  RE_DATA_URI = ///^
                  data:
                  (?:              # Media
                    ([^;,]*)       # MIME type
                    (?:;([^;,]*))? # Charset
                  )?
                  (;base64)?       # Base-64?
                  \s*,(.*)         # Data
                ///i


  class URLData extends String
    constructor: (data, quote, charset, @mime) ->
      super data, quote, charset

    @property 'mime',
      get: ->
      set: (value) ->

    @property 'media',
      get: ->
      set: (value) ->

  @COMPONENTS = [
    'scheme'
    'username'
    'password'
    'host'
    'port'
    'path'
    'query'
    'fragment'
  ]

  @ALIAS_COMPONENTS =
    protocol: 'scheme'
    hash: 'fragment'

  constructor: (@value = '', @quote = null) ->

  _parseDataURI: (value) ->
    # TODO Do not just use this regexp. Try to detect malformed data URIs
    if m = RE_DATA_URI.exec value
      @components = scheme: 'data'
      mime = m[1] or null
      charset = m[2] or 'us-ascii'
      base64 = !!m[3]
      data = m[4]
      @data = new URLData m[4], '"', charset
      return yes

    return no

  @property 'value',
    get: -> @toString()
    set: (value) ->
      value = value.trim()

      unless no and @_parseDataURI value
        try
          @components = parseURL.parse value.trim(), no, yes
          @components.host = null
        catch e
          throw e # TODO

  @property 'scheme',
    get: ->
      @components.protocol and
      @components.protocol[0...@components.protocol.length - 1]
    set:(value) ->
      if value
        value = "#{value}:"
      @components.protocol = value

  @property 'auth',
    get: -> @components.auth
    set: (value) ->
      @components.auth = value

  makeAuth: (user, pass) ->
    @auth =
      if user?
        if pass?
          "#{user}:#{pass}"
        else
          user
      else if pass?
        ":#{pass}"
      else
        null

  @property 'username',
    get: ->
      if @auth?
        user = (@auth.split ':')[0]
      user ?= null
      user
    set: (value) ->
      @makeAuth value, @password

  @property 'password',
    get: ->
      if @auth
        pass = (@auth.split ':')[1]
      pass ?= null
    set: (value) ->
      @makeAuth @username, value

  @property 'host',
    get: ->
      if @components.hostname is null then null else @components.hostname
    set: (value) ->
      @components.hostname = value

  @property 'port',
    get: -> @components.port
    set: (value) ->
      @components.port = value

  @property 'path',
    get: -> @components.pathname
    set: (value) -> @components.pathname = value

  @property 'query',
    get: ->  @components.search and @components.search[1..]
    set: (value) ->
      if value isnt null
        value = "?#{value}"
      @components.search = value

  @property 'fragment',
    get: -> @components.hash and @components.hash[1..]
    set: (value) ->
      if value isnt null
        value = "##{value}"
      @components.hash = value

  @property 'dirname',
    get: ->
      if @path then Path.dirname @path else null
    set: (value) ->
      value = if value? then value else ''
      @path = Path.join '/', value, @basename

  @property 'basename',
    get: ->
      if @path then Path.basename @path else null
    set: (value) ->
      value = if value? then value else ''
      @path = Path.join '/', @dirname, value

  @property 'extname',
    get: ->
      if @path then Path.extname @path else null
    set: (value) ->
      value = if value? then value else ''
      basename = @filename + value
      @path = Path.join '/', @dirname, basename

  @property 'filename',
    get: ->
      if @path
        Path.basename @path, @extname

    set: (value) ->
      value = if value? then value else ''
      @path = Path.join '/', @dirname, "#{value}#{@extname}"

  clone: (value = @value, quote = @quote) ->
    super value, quote

  toString: ->
    parseURL.format @components

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

  '.port=': (value) ->
    unless value.isNull()
      if not (value instanceof Number)
        try
          value = value.toNumber()
        catch
          throw new TypeError (
            "Cannot set URL port to non-numeric value: #{value.repr()}"
          )

      unless value.isPure()
        throw new TypeError (
          "Cannot set URL port to non-pure number: #{value.reprValue()}"
        )

      unless value.isInteger()
        throw new TypeError (
          "Cannot set URL port to non-integer number: #{value.reprValue()}"
        )

      unless 0 <= value.value <= 65535
        throw new TypeError (
          "Port number out of 1..65535 range: #{value.reprValue()}"
        )

    @port = value.value

  @COMPONENTS.forEach (component) =>
    @::[".#{component}"] ?= ->
      value = @[component]

      if value is null
        Null.null
      else
        new String value, @quote or '"'

    @::[".#{component}?"] ?= -> Boolean.new @[component]

    @::[".#{component}="] ?= (value) ->
      value = if value.isNull() then null else value.toString()
      @[component] = value

  for alias of @ALIAS_COMPONENTS
    @::[".#{alias}"] ?= @::[".#{@ALIAS_COMPONENTS[alias]}"]
    @::[".#{alias}?"] ?= @::[".#{@ALIAS_COMPONENTS[alias]}?"]
    @::[".#{alias}="] ?= @::[".#{@ALIAS_COMPONENTS[alias]}="]

  '.absolute?': -> Boolean.new @scheme

  '.relative?': -> Boolean.new not @scheme

  '.http?': -> Boolean.new @scheme is 'http'

  '.http': -> @clone().set scheme: 'http'

  '.https?': -> Boolean.new @scheme is 'https'

  '.https': -> @clone().set scheme: 'https'

  # Returns `true` if the host is a v4 IP
  '.ipv4?': -> Boolean.new Net.isIPv4 @host

  # Returns `true` if the host is a v6 IP
  '.ipv6?': -> Boolean.new Net.isIPv6 @host

  # Returns `true` if the host is an IP (v4 or v6)
  '.ip?': -> Boolean.new Net.isIP @host

  '.domain': ->
    domain = @host
    if domain?
      if domain[0..3] is 'www.'
        domain = domain.substr 4
      new String domain, @quote or '"'
    else
      Null.null

  do =>
    pathInfo = (url, comp, etc...) ->
      if url.path?
        component = Path["#{comp}name"] url.path
        if component isnt ''
          return new String component, url.quote or '"'

      null

    ['dir', 'base', 'ext', 'file'].forEach (comp) =>
      name = "#{comp}name"

      @::[".#{name}"] = ->
        value = @[name]

        if value?
          new String value, @quote or '"'

      @::[".#{name}="] = (value) ->
        if not value.isNull()
          value = value.toString()
        else
          value = null

        @[name] = value

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
