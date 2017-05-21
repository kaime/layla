###
The base for most Layla classes.

TODO Rename to `Base`? `Class` is a bit agressive IMHO
###
class Class

  @NOT_IMPLEMENTED: (name) -> throw new Error 'Not implemented'

  { getOwnPropertyDescriptor, defineProperty } = Object

  ###
  Simple property support. Allows subclasses to define their own property
  accessors.
  ###
  @property: (name, desc) ->
    if '@' is name.charAt 0
      name = name.substr 1
      target = @
    else
      target = @::

    desc.enumerable ?= yes
    desc.configurable ?= yes

    # If the property already existed for this prototype, inherit its
    # descriptor, so properties can be partially overloaded.
    if target.hasOwnProperty name
      current = getOwnPropertyDescriptor target,  name
      desc[k] ?= v for k, v of current

    defineProperty target, name, desc

  @property 'class',
    get: -> @constructor

  @property 'type',
    get: -> @class.name

  clone: (etc...) -> new @class etc...

  toJSON: -> {}

module.exports = Class
