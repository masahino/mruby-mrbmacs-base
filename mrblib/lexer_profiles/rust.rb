module Mrbmacs
  RUST_KEYWORDS = "as fn let const static if else match for in loop \
      while break continue return crate extern use mod self super struct \
      enum union trait type where impl Self self pub unsafe true false \
      move mut ref box do catch default"

  RUST_LEXER_PROFILE = LexerProfile.new(
    :rust,
    'rust',
    {
      Scintilla::SCE_RUST_DEFAULT => :default,
      Scintilla::SCE_RUST_COMMENTBLOCK => :comment,
      Scintilla::SCE_RUST_COMMENTLINE => :comment,
      Scintilla::SCE_RUST_COMMENTBLOCKDOC => :documentation,
      Scintilla::SCE_RUST_COMMENTLINEDOC => :documentation,
      Scintilla::SCE_RUST_NUMBER => :number,
      Scintilla::SCE_RUST_WORD => :keyword,
      Scintilla::SCE_RUST_WORD2 => :keyword,
      Scintilla::SCE_RUST_WORD3 => :keyword,
      Scintilla::SCE_RUST_WORD4 => :keyword,
      Scintilla::SCE_RUST_WORD5 => :keyword,
      Scintilla::SCE_RUST_WORD6 => :keyword,
      Scintilla::SCE_RUST_WORD7 => :keyword,
      Scintilla::SCE_RUST_STRING => :string,
      Scintilla::SCE_RUST_STRINGR => :string,
      Scintilla::SCE_RUST_CHARACTER => :string,
      Scintilla::SCE_RUST_OPERATOR => :operator,
      Scintilla::SCE_RUST_IDENTIFIER => :default,
      Scintilla::SCE_RUST_LIFETIME => :variable_name,
      Scintilla::SCE_RUST_MACRO => :builtin,
      Scintilla::SCE_RUST_LEXERROR => :error,
      Scintilla::SCE_RUST_BYTESTRING => :string,
      Scintilla::SCE_RUST_BYTESTRINGR => :string,
      Scintilla::SCE_RUST_BYTECHARACTER => :string
    },
    { 0 => RUST_KEYWORDS },
    { 'fold.compact' => '1' }
  )
end
