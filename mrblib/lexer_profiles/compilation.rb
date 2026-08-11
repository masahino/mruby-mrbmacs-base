module Mrbmacs
  COMPILATION_STYLE_DEFAULT = 0
  COMPILATION_STYLE_ERROR = 1
  COMPILATION_STYLE_FILE = 2
  COMPILATION_STYLE_NUMBER = 3

  COMPILATION_LEXER_PROFILE = LexerProfile.new(
    :compilation,
    nil,
    {
      COMPILATION_STYLE_DEFAULT => :default,
      COMPILATION_STYLE_ERROR => :error,
      COMPILATION_STYLE_FILE => :markup_link,
      COMPILATION_STYLE_NUMBER => :number
    }
  )
end
