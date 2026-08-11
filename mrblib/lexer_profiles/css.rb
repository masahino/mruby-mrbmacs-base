module Mrbmacs
  CSS_KEYWORDS = ''

  CSS_LEXER_PROFILE = LexerProfile.new(
    :css,
    'css',
    {
      Scintilla::SCE_CSS_DEFAULT => :default,
      Scintilla::SCE_CSS_TAG => :type,
      Scintilla::SCE_CSS_CLASS => :variable_name,
      Scintilla::SCE_CSS_PSEUDOCLASS => :type,
      Scintilla::SCE_CSS_UNKNOWN_PSEUDOCLASS => :error,
      Scintilla::SCE_CSS_OPERATOR => :operator,
      Scintilla::SCE_CSS_IDENTIFIER => :constant,
      Scintilla::SCE_CSS_UNKNOWN_IDENTIFIER => :error,
      Scintilla::SCE_CSS_VALUE => :default,
      Scintilla::SCE_CSS_COMMENT => :comment,
      Scintilla::SCE_CSS_ID => :variable_name,
      Scintilla::SCE_CSS_IMPORTANT => :keyword,
      Scintilla::SCE_CSS_DIRECTIVE => :keyword,
      Scintilla::SCE_CSS_DOUBLESTRING => :string,
      Scintilla::SCE_CSS_SINGLESTRING => :string,
      Scintilla::SCE_CSS_IDENTIFIER2 => :constant,
      Scintilla::SCE_CSS_ATTRIBUTE => :variable_name,
      Scintilla::SCE_CSS_IDENTIFIER3 => :constant,
      Scintilla::SCE_CSS_PSEUDOELEMENT => :type,
      Scintilla::SCE_CSS_EXTENDED_IDENTIFIER => :constant,
      Scintilla::SCE_CSS_EXTENDED_PSEUDOCLASS => :type,
      Scintilla::SCE_CSS_EXTENDED_PSEUDOELEMENT => :type,
      Scintilla::SCE_CSS_GROUP_RULE => :keyword,
      Scintilla::SCE_CSS_VARIABLE => :variable_name
    },
    { 0 => CSS_KEYWORDS },
    { 'fold.compact' => '1' }
  )
end
