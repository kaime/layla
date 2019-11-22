Object  = require '../object'
Boolean = require './boolean'


###
###
class Null extends Object

  @NULL = new @

  @new: -> @NULL

  @ifNull: (value) ->
    if value? then value else @NULL

  toString: -> ''

  isEqual: (other) -> other.isNull()

  isNull: -> yes

  isEmpty: -> yes

  toBoolean: -> no

  clone: -> @

Object::isNull = -> no

Object::['.null?'] = -> Boolean.new @isNull()


module.exports = Null
