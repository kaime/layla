Visitor       = require '../lib/visitor'
Block         = require '../lib/object/block'
Rule          = require '../lib/object/rule'
RuleSet       = require '../lib/object/rule-set'
AtRule        = require '../lib/object/at-rule'
Property      = require '../lib/object/property'
Null          = require '../lib/object/null'
InternalError = require '../lib/error/internal'


###
###
class Normalizer extends Visitor

  options: null
  indentation: 0

  constructor: (@options = {}) ->
    super()

    defaults =
      flatten_block_properties:   yes
      strip_root_properties:      no
      strip_empty_blocks:         no
      strip_null_properties:      no
      strip_empty_properties:     no
      strip_empty_rule_sets:      yes
      strip_empty_at_rules:       no
      strip_empty_media_at_rules: yes
      hoist_rule_sets:            yes
      hoist_at_rules:             no
      hoist_media_at_rules:       yes

    for name of defaults
      @options[name] = defaults[name] unless name of @options

  ###
  ###
  normalize: (node) ->
    method = "normalize#{node.type}"

    if method of this
      this[method].call this, node
    else
      node

  normalizeRule: (node, root) -> node

  isEmptyProperty: (node) -> node.value instanceof Null

  normalizeBlock: (node, root) ->
    if body = node.items
      root ?= node
      node.items = []
      child = null

      while body.length
        child = body.shift()

        if child instanceof Rule
          parent = node

          if child instanceof RuleSet
            hoist = (
              (node instanceof RuleSet) and
              @options.hoist_rule_sets
            )

            if hoist
              child.selector = child.selector.resolve node.selector
              root.items.push child
              parent = root
            else
              node.items.push child
          else if child instanceof AtRule
            hoist = (
              (node instanceof RuleSet) and
              (@options.hoist_at_rules or
              @options["hoist_#{child.name}_at_rules"])
            )

            if hoist
              rule_set = node.copy child.items
              child.empty()
              child.push rule_set
              root.items.push child
              child = rule_set
              parent = root
            else
              node.items.push child
          else
            node.items.push child

          @normalizeBlock child, root

          strip =
            not child.items.length and (
              @options.strip_empty_blocks or
              (child instanceof RuleSet and @options.strip_empty_rule_sets) or
              (child instanceof RuleSet and (
                @options.strip_empty_rule_sets or
                @options["strip_empty_#{child.name}_at_rules"]
              ))
            )

          if strip
            parent.items.splice parent.items.indexOf(child), 1
        else if child instanceof Property
          if @options.strip_empty_properties and @isEmptyProperty child
            continue

          if @options.flatten_block_properties and child.value instanceof Block
            for grandchild in child.value.items
              if grandchild instanceof Property
                name = "#{child.name}-#{grandchild.name}"
                value = grandchild.value
                value = @normalize value
                node.items.push new Property name, value
          else
            child.value = @normalize child.value
            node.items.push child

        else
          throw new InternalError # This should never happen

    return node

  ###
  ###
  normalizeDocument: (node) -> @normalizeBlock node


module.exports = Normalizer
