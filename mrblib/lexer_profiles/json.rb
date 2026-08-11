module Mrbmacs
  JSON_LEXER_PROFILE = LexerProfile.new(
    :json,
    'json',
    {
      Scintilla::SCE_JSON_DEFAULT => :default,
      Scintilla::SCE_JSON_NUMBER => :number,
      Scintilla::SCE_JSON_STRING => :string,
      Scintilla::SCE_JSON_STRINGEOL => :string,
      Scintilla::SCE_JSON_PROPERTYNAME => :variable_name,
      Scintilla::SCE_JSON_ESCAPESEQUENCE => :escape,
      Scintilla::SCE_JSON_LINECOMMENT => :comment,
      Scintilla::SCE_JSON_BLOCKCOMMENT => :comment,
      Scintilla::SCE_JSON_OPERATOR => :operator,
      Scintilla::SCE_JSON_URI => :markup_link,
      Scintilla::SCE_JSON_COMPACTIRI => :markup_link,
      Scintilla::SCE_JSON_KEYWORD => :keyword,
      Scintilla::SCE_JSON_LDKEYWORD => :keyword,
      Scintilla::SCE_JSON_ERROR => :error
    },
    { 0 => '' },
    {}
  )
end
