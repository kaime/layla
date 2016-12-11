Class = require './class'

class Token extends Class

  # Types
  #
  @RAW_STRING      = 'RawString'
  @UNQUOTED_STRING = 'UnquotedString'
  @QUOTED_STRING   = 'QuotedString'
  @HASH            = 'Hash'
  @NUMBER          = 'Number'
  @COLOR           = 'Color'
  @REGEXP          = 'RegExp'
  @URL             = 'URL'
  @CALC            = 'Calc'
  @CALl            = 'Call'
  @UNICODE_RANGE   = 'UnicodeRange'

  @TILDE_EQUAL     = 'TildeEqual'
  @CARET_EQUAL     = 'CaretEqual'
  @DOLLAR_EQUAL    = 'DollarEqual'
  @ASTERISK_EQUAL  = 'AsteriskEqual'
  @LT_EQUAL        = 'LTEqual'
  @GT_EQUAL        = 'GTEqual'
  @PIPE            = 'Pipe'
  @PIPE_EQUAL      = 'PipeEqual'
  @PUSH_RIGHT      = 'PushRight'
  @PUSH_LEFT       = 'PushLeft'
  @DOUBLE_COLON    = 'DoubleColon'
  @DOUBLE_DOT      = 'DoubleDot'
  @EQUAL           = 'Equal'
  @DOT             = 'Dot'
  @ASTERISK        = 'Asterisk'
  @SLASH           = 'Slash'
  @PLUS            = 'Plus'
  @MINUS           = 'Minus'
  @LT              = 'Lt'
  @GT              = 'Gt'
  @TILDE           = 'Tilde'
  @COMMA           = 'Comma'
  @PIPE_COLON      = 'PipeColon'
  @COLON           = 'Colon'
  @AT_SYMBOL       = 'AtSymbol'
  @AMPERSAND       = 'Ampersand'
  @PERCENT         = 'Percent'
  @SEMICOLON       = 'Semicolon'
  @PAREN_OPEN      = 'ParenOpen'
  @PAREN_CLOSE     = 'ParenClose'
  @CURLY_OPEN      = 'CurlyOpen'
  @CURLY_CLOSE     = 'CurlyClose'
  @BRACKET_OPEN    = 'BracketOpen'
  @BRACKET_CLOSE   = 'BracketClose'

  @H_WHITESPACE    = 'HorizontalWhitespace'
  @V_WHITESPACE    = 'VerticalWhitespace'
  @BOM             = 'BOM'
  @EOF             = 'EOF'

  # Next token
  next: null

  ###
  ###
  constructor: (@kind, @start = null, @end = null, @value = null) ->

  is: (kind, value) -> (kind is @kind) and (not value or @value in value)

  toJSON: ->
    json = super
    json.kind = @kind
    json.start = @start
    json.end = @end
    json.value = @value

    return json

module.exports = Token
