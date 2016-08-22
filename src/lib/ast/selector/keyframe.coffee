Selector = require '../selector'

class KeyframeSelector extends Selector

  constructor: (@keyframe) ->

  toJSON: ->
    json = super
    json.keyframe = @keyframe
    json

module.exports = KeyframeSelector
