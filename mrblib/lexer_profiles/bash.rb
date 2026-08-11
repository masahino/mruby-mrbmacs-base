module Mrbmacs
  BASH_KEYWORDS = ''

  BASH_LEXER_PROFILE = LexerProfile.new(
    :bash,
    'bash',
    {
      Scintilla::SCE_SH_DEFAULT => :default,
      Scintilla::SCE_SH_ERROR => :error,
      Scintilla::SCE_SH_COMMENTLINE => :comment,
      Scintilla::SCE_SH_NUMBER => :number,
      Scintilla::SCE_SH_WORD => :keyword,
      Scintilla::SCE_SH_STRING => :string,
      Scintilla::SCE_SH_CHARACTER => :string,
      Scintilla::SCE_SH_OPERATOR => :operator,
      Scintilla::SCE_SH_IDENTIFIER => :default,
      Scintilla::SCE_SH_SCALAR => :variable_name,
      Scintilla::SCE_SH_PARAM => :variable_name,
      Scintilla::SCE_SH_BACKTICKS => :string,
      Scintilla::SCE_SH_HERE_DELIM => :string,
      Scintilla::SCE_SH_HERE_Q => :string
    },
    { 0 => BASH_KEYWORDS },
    { 'fold.compact' => '1' }
  )
end
