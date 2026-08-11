module Mrbmacs
  HASKELL_KEYWORDS = "case class data default deriving do else hiding if \
      import in infix infixl infixr instance let module \
      newtype of then type where forall foreign"

  HASKELL_LEXER_PROFILE = LexerProfile.new(
    :haskell,
    'haskell',
    {
      Scintilla::SCE_HA_DEFAULT => :default,
      Scintilla::SCE_HA_IDENTIFIER => :default,
      Scintilla::SCE_HA_KEYWORD => :keyword,
      Scintilla::SCE_HA_NUMBER => :number,
      Scintilla::SCE_HA_STRING => :string,
      Scintilla::SCE_HA_CHARACTER => :string,
      Scintilla::SCE_HA_CLASS => :type,
      Scintilla::SCE_HA_MODULE => :type,
      Scintilla::SCE_HA_CAPITAL => :default,
      Scintilla::SCE_HA_DATA => :keyword,
      Scintilla::SCE_HA_IMPORT => :keyword,
      Scintilla::SCE_HA_OPERATOR => :operator,
      Scintilla::SCE_HA_INSTANCE => :keyword,
      Scintilla::SCE_HA_COMMENTLINE => :comment,
      Scintilla::SCE_HA_COMMENTBLOCK => :comment,
      Scintilla::SCE_HA_COMMENTBLOCK2 => :comment,
      Scintilla::SCE_HA_COMMENTBLOCK3 => :comment,
      Scintilla::SCE_HA_PRAGMA => :preprocessor,
      Scintilla::SCE_HA_PREPROCESSOR => :preprocessor,
      Scintilla::SCE_HA_STRINGEOL => :string,
      Scintilla::SCE_HA_RESERVED_OPERATOR => :operator,
      Scintilla::SCE_HA_LITERATE_COMMENT => :comment,
      Scintilla::SCE_HA_LITERATE_CODEDELIM => :markup_code
    },
    { 0 => HASKELL_KEYWORDS },
    { 'fold.compact' => '1' }
  )
end
