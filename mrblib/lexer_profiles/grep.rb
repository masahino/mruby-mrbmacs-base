module Mrbmacs
  GREP_STYLE_DEFAULT = 0
  GREP_STYLE_FILE = 1
  GREP_STYLE_NUMBER = 2
  GREP_STYLE_PATTERN = 3

  GREP_LEXER_PROFILE = LexerProfile.new(
    :grep,
    nil,
    {
      GREP_STYLE_DEFAULT => :default,
      GREP_STYLE_FILE => :markup_link,
      GREP_STYLE_NUMBER => :number,
      GREP_STYLE_PATTERN => :warning
    }
  )
end
