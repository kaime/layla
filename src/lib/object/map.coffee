Indexed = require './indexed'

###
###
class Map extends Indexed

  constructor: (@keys = [], @values = []) -> super()

  @property 'length',
    get: -> @keys.length

  keyToIndex: (key) -> @keys.indexOf key

  indexToKey: (index) -> @keys[index]

  getByIndex: (index) -> @values[index]

  # TODO optimize this
  pop: (keys...) ->
    if not keys.length
      @keys.pop()
      @values.pop()
    else
      for key in keys
        index = @index(key)

        if @hasIndex index
          @keys.splice index, 1
          @values.splice index, 1

    return @

  isEqual: (other) -> (other instanceof Map) and super(other)

  reprValue: -> "#{@length}"

  toJSON: ->
    json = super()
    json.data = {}
    @each (key, value) -> data[key] = value.toJSON()

    return json

  '.::=': (key, value) ->

  '.+': (other) ->


module.exports = Map
