module Mrbmacs
  RUBY_KEYWORDS = 'attr_accessor attr_reader attr_writer module_function begin break elsif module retry unless end case next return until class ensure nil self when def false not super while alias defined? for or then yield and do if redo true else in rescue undef'

  # Semantic mapping for styles distinguished by Lexilla's Ruby lexer.
  RUBY_LEXER_PROFILE = LexerProfile.new(
    :ruby,
    'ruby',
    {
      Scintilla::SCE_RB_DEFAULT => :default,
      Scintilla::SCE_RB_ERROR => :error,
      Scintilla::SCE_RB_COMMENTLINE => :comment,
      Scintilla::SCE_RB_POD => :documentation,
      Scintilla::SCE_RB_NUMBER => :number,
      Scintilla::SCE_RB_WORD => :keyword,
      Scintilla::SCE_RB_STRING => :string,
      Scintilla::SCE_RB_CHARACTER => :string,
      Scintilla::SCE_RB_CLASSNAME => :type,
      Scintilla::SCE_RB_DEFNAME => :function_name,
      Scintilla::SCE_RB_OPERATOR => :operator,
      Scintilla::SCE_RB_IDENTIFIER => :default,
      Scintilla::SCE_RB_REGEX => :regexp,
      Scintilla::SCE_RB_GLOBAL => :variable_use,
      Scintilla::SCE_RB_SYMBOL => :constant,
      Scintilla::SCE_RB_MODULE_NAME => :type,
      Scintilla::SCE_RB_INSTANCE_VAR => :variable_use,
      Scintilla::SCE_RB_CLASS_VAR => :variable_use,
      Scintilla::SCE_RB_BACKTICKS => :string,
      Scintilla::SCE_RB_DATASECTION => :documentation,
      Scintilla::SCE_RB_HERE_DELIM => :delimiter,
      Scintilla::SCE_RB_HERE_Q => :string,
      Scintilla::SCE_RB_HERE_QQ => :string,
      Scintilla::SCE_RB_HERE_QX => :string,
      Scintilla::SCE_RB_STRING_Q => :string,
      Scintilla::SCE_RB_STRING_QQ => :string,
      Scintilla::SCE_RB_STRING_QX => :string,
      Scintilla::SCE_RB_STRING_QR => :regexp,
      Scintilla::SCE_RB_STRING_QW => :string,
      Scintilla::SCE_RB_WORD_DEMOTED => :default,
      Scintilla::SCE_RB_STDIN => :builtin,
      Scintilla::SCE_RB_STDOUT => :builtin,
      Scintilla::SCE_RB_STDERR => :builtin,
      Scintilla::SCE_RB_STRING_W => :string,
      Scintilla::SCE_RB_STRING_I => :string,
      Scintilla::SCE_RB_STRING_QI => :string,
      Scintilla::SCE_RB_STRING_QS => :string
    },
    { 0 => RUBY_KEYWORDS },
    { 'fold' => '1' }
  )
end
