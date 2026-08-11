module Mrbmacs
  R_KEYWORDS = 'if else repeat while function for in next break TRUE FALSE NULL NA Inf NaN'

  R_LEXER_PROFILE = LexerProfile.new(
    :r,
    'r',
    {
      Scintilla::SCE_R_DEFAULT => :default,
      Scintilla::SCE_R_COMMENT => :comment,
      Scintilla::SCE_R_KWORD => :keyword,
      Scintilla::SCE_R_BASEKWORD => :keyword,
      Scintilla::SCE_R_OTHERKWORD => :keyword,
      Scintilla::SCE_R_NUMBER => :number,
      Scintilla::SCE_R_STRING => :string,
      Scintilla::SCE_R_STRING2 => :string,
      Scintilla::SCE_R_OPERATOR => :operator,
      Scintilla::SCE_R_IDENTIFIER => :default,
      Scintilla::SCE_R_INFIX => :operator,
      Scintilla::SCE_R_INFIXEOL => :operator
    },
    { 0 => R_KEYWORDS },
    { 'fold.compact' => '1' }
  )
end
