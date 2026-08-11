module Mrbmacs
  YAML_KEYWORDS = ''

  YAML_LEXER_PROFILE = LexerProfile.new(
    :yaml,
    'yaml',
    {
      Scintilla::SCE_YAML_DEFAULT => :default,
      Scintilla::SCE_YAML_COMMENT => :comment,
      Scintilla::SCE_YAML_IDENTIFIER => :variable_name,
      Scintilla::SCE_YAML_KEYWORD => :keyword,
      Scintilla::SCE_YAML_NUMBER => :number,
      Scintilla::SCE_YAML_REFERENCE => :constant,
      Scintilla::SCE_YAML_DOCUMENT => :constant,
      Scintilla::SCE_YAML_TEXT => :string,
      Scintilla::SCE_YAML_ERROR => :error,
      Scintilla::SCE_YAML_OPERATOR => :operator
    },
    { 0 => YAML_KEYWORDS },
    { 'fold.compact' => '1' }
  )
end
