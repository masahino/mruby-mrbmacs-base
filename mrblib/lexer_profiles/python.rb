module Mrbmacs
  PYTHON_KEYWORDS = "and as assert break class continue def del elif else except exec finally for from \
    global if import in is lambda not or pass print raise return try while with yield"

  # Semantic mapping and Lexilla configuration for the Python lexer.
  PYTHON_LEXER_PROFILE = LexerProfile.new(
    :python,
    'python',
    {
      Scintilla::SCE_P_DEFAULT => :default,
      Scintilla::SCE_P_COMMENTLINE => :comment,
      Scintilla::SCE_P_NUMBER => :number,
      Scintilla::SCE_P_STRING => :string,
      Scintilla::SCE_P_CHARACTER => :string,
      Scintilla::SCE_P_WORD => :keyword,
      Scintilla::SCE_P_TRIPLE => :string,
      Scintilla::SCE_P_TRIPLEDOUBLE => :string,
      Scintilla::SCE_P_CLASSNAME => :type,
      Scintilla::SCE_P_DEFNAME => :function_name,
      Scintilla::SCE_P_OPERATOR => :operator,
      Scintilla::SCE_P_IDENTIFIER => :default,
      Scintilla::SCE_P_COMMENTBLOCK => :comment,
      Scintilla::SCE_P_STRINGEOL => :error,
      Scintilla::SCE_P_WORD2 => :keyword,
      Scintilla::SCE_P_DECORATOR => :builtin,
      Scintilla::SCE_P_FSTRING => :string,
      Scintilla::SCE_P_FCHARACTER => :string,
      Scintilla::SCE_P_FTRIPLE => :string,
      Scintilla::SCE_P_FTRIPLEDOUBLE => :string,
      Scintilla::SCE_P_ATTRIBUTE => :property_use
    },
    {
      0 => PYTHON_KEYWORDS,
      1 => ''
    },
    { 'fold' => '1' }
  )
end
