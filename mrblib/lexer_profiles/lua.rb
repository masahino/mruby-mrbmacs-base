module Mrbmacs
  LUA_KEYWORDS = ''

  LUA_LEXER_PROFILE = LexerProfile.new(
    :lua,
    'lua',
    {
      Scintilla::SCE_LUA_DEFAULT => :default,
      Scintilla::SCE_LUA_COMMENT => :comment,
      Scintilla::SCE_LUA_COMMENTLINE => :comment,
      Scintilla::SCE_LUA_COMMENTDOC => :documentation,
      Scintilla::SCE_LUA_NUMBER => :number,
      Scintilla::SCE_LUA_WORD => :keyword,
      Scintilla::SCE_LUA_STRING => :string,
      Scintilla::SCE_LUA_CHARACTER => :string,
      Scintilla::SCE_LUA_LITERALSTRING => :string,
      Scintilla::SCE_LUA_PREPROCESSOR => :preprocessor,
      Scintilla::SCE_LUA_OPERATOR => :operator,
      Scintilla::SCE_LUA_IDENTIFIER => :default,
      Scintilla::SCE_LUA_STRINGEOL => :string,
      Scintilla::SCE_LUA_WORD2 => :keyword,
      Scintilla::SCE_LUA_WORD3 => :keyword,
      Scintilla::SCE_LUA_WORD4 => :keyword,
      Scintilla::SCE_LUA_WORD5 => :keyword,
      Scintilla::SCE_LUA_WORD6 => :keyword,
      Scintilla::SCE_LUA_WORD7 => :keyword,
      Scintilla::SCE_LUA_WORD8 => :keyword,
      Scintilla::SCE_LUA_LABEL => :label
    },
    { 0 => LUA_KEYWORDS },
    { 'fold.compact' => '1' }
  )
end
