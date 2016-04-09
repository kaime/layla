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

  @COMPONENTS = [
    'scheme'
    'auth'
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

  @property 'value',
    get: -> @toString()
    set: (value) ->
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
    set: (value) -> @components.auth = value

  @property 'username',
    get: ->
      (@auth and (@auth.split ':')[0]) or null
    set: ->

  @property 'password',
    get: ->
      (@auth and (@auth.split ':')[1]) or null
    set: ->

  @property 'host',
    get: ->
      if @components.hostname is null then null else @components.hostname
    set: (value) ->
      @components.hostname = value

  @property 'port',
    get: -> @components.port
    set: (value) ->
      # TODO Validate
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
      if @pathname then Path.dirname @pathname else null
    set: (value) ->
      value = if value? then value else ''
      @pathname = Path.join '/', value, @basename

  @property 'basename',
    get: ->
      if @pathname then Path.basename @pathname else null
    set: (value) ->
      value = if value? then value else ''
      @pathname = Path.join '/', @dirname, value

  @property 'extname',
    get: ->
      if @pathname then Path.extname @pathname else null
    set: (value) ->
      value = if value? then value else ''
      basename = @filename + value
      @pathname = Path.join '/', @dirname, basename

  @property 'filename',
    get: ->
      if @pathname
        Path.basename @pathname, @extname

    set: (value) ->
      value = if value? then value else ''
      @pathname = Path.join '/', @dirname, "#{value}#{@extname}"

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

  @COMPONENTS.forEach (component) =>
    @::[".#{component}"] = ->
      value = @[component]

      if value is null
        Null.null
      else
        new String value, @quote or '"'

    @::[".#{component}?"] = -> Boolean.new @[component]

    @::[".#{component}="] = (value) ->
      value = if value.isNull() then null else value.toString()
      @[component] = value

  for alias of @ALIAS_COMPONENTS
    @::[".#{alias}"] = @::[".#{@ALIAS_COMPONENTS[alias]}"]
    @::[".#{alias}?"] = @::[".#{@ALIAS_COMPONENTS[alias]}?"]
    @::[".#{alias}="] = @::[".#{@ALIAS_COMPONENTS[alias]}="]

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

    ['dir', 'base', 'ext'].forEach (comp) =>
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

  '.filename': ->

  '.filename=': ->

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
