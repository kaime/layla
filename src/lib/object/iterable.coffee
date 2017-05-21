Object = require '../object'


###
###
class Iterable extends Object

  reset: @NOT_IMPLEMENTED

  next: @NOT_IMPLEMENTED

  each: @NOT_IMPLEMENTED

  done: @NOT_IMPLEMENTED

  isIterable: -> yes

Object::isIterable = -> no


module.exports = Iterable
