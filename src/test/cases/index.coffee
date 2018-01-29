Tests       = require './tests'
NodeContext = require '../../node/context'

describe 'Cases', ->
  Tests.run __dirname, new NodeContext



