module Mrbmacs
  TEX_KEYWORDS = ''

  TEX_LEXER_PROFILE = LexerProfile.new(
    :latex,
    'latex',
    {
      Scintilla::SCE_L_DEFAULT => :default,
      Scintilla::SCE_L_COMMAND => :keyword,
      Scintilla::SCE_L_TAG => :variable_name,
      Scintilla::SCE_L_MATH => :constant,
      Scintilla::SCE_L_COMMENT => :comment,
      Scintilla::SCE_L_TAG2 => :variable_name,
      Scintilla::SCE_L_MATH2 => :constant,
      Scintilla::SCE_L_COMMENT2 => :comment,
      Scintilla::SCE_L_VERBATIM => :string,
      Scintilla::SCE_L_SHORTCMD => :keyword,
      Scintilla::SCE_L_SPECIAL => :constant,
      Scintilla::SCE_L_CMDOPT => :keyword,
      Scintilla::SCE_L_ERROR => :error
    },
    { 0 => TEX_KEYWORDS },
    { 'fold.compact' => '1' }
  )
end
