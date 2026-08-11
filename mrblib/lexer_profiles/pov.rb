module Mrbmacs
  POV_KEYWORDS = ''

  POV_LEXER_PROFILE = LexerProfile.new(
    :pov,
    'pov',
    {
      Scintilla::SCE_POV_DEFAULT => :default,
      Scintilla::SCE_POV_COMMENT => :comment,
      Scintilla::SCE_POV_COMMENTLINE => :comment,
      Scintilla::SCE_POV_NUMBER => :number,
      Scintilla::SCE_POV_OPERATOR => :operator,
      Scintilla::SCE_POV_IDENTIFIER => :default,
      Scintilla::SCE_POV_STRING => :string,
      Scintilla::SCE_POV_STRINGEOL => :string,
      Scintilla::SCE_POV_DIRECTIVE => :preprocessor,
      Scintilla::SCE_POV_BADDIRECTIVE => :error,
      Scintilla::SCE_POV_WORD2 => :keyword,
      Scintilla::SCE_POV_WORD3 => :keyword,
      Scintilla::SCE_POV_WORD4 => :keyword,
      Scintilla::SCE_POV_WORD5 => :keyword,
      Scintilla::SCE_POV_WORD6 => :keyword,
      Scintilla::SCE_POV_WORD7 => :keyword,
      Scintilla::SCE_POV_WORD8 => :keyword
    },
    { 0 => POV_KEYWORDS },
    { 'fold.compact' => '1' }
  )
end
