module Mrbmacs
  MAKE_KEYWORDS = ''

  MAKE_LEXER_PROFILE = LexerProfile.new(
    :make,
    'makefile',
    {
      Scintilla::SCE_MAKE_DEFAULT => :default,
      Scintilla::SCE_MAKE_COMMENT => :comment,
      Scintilla::SCE_MAKE_PREPROCESSOR => :preprocessor,
      Scintilla::SCE_MAKE_IDENTIFIER => :variable_name,
      Scintilla::SCE_MAKE_OPERATOR => :operator,
      Scintilla::SCE_MAKE_TARGET => :function_name,
      Scintilla::SCE_MAKE_IDEOL => :error
    },
    { 0 => MAKE_KEYWORDS },
    { 'fold.compact' => '1' }
  )
end
