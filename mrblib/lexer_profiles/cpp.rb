module Mrbmacs
  CPP_KEYWORDS = 'and and_eq asm auto bitand bitor bool break case catch char class compl const const_cast constexpr continue default delete do double dynamic_cast else enum explicit export extern false float for friend goto if inline int long mutable namespace new not not_eq operator or or_eq private protected public register reinterpret_cast return short signed sizeof static static_cast struct switch template this throw true try typedef typeid typename union unsigned using virtual void volatile wchar_t while xor xor_eq'
  CPP_DOCUMENTATION_KEYWORDS = 'brief class code def enum example exception file fn param return see struct throws todo typedef var warning'
  C_LIKE_TASK_MARKERS = 'TODO FIXME XXX BUG HACK'

  C_LIKE_LEXER_STYLES = {
    Scintilla::SCE_C_DEFAULT => :default,
    Scintilla::SCE_C_COMMENT => :comment,
    Scintilla::SCE_C_COMMENTLINE => :comment,
    Scintilla::SCE_C_COMMENTDOC => :documentation,
    Scintilla::SCE_C_NUMBER => :number,
    Scintilla::SCE_C_WORD => :keyword,
    Scintilla::SCE_C_STRING => :string,
    Scintilla::SCE_C_CHARACTER => :string,
    Scintilla::SCE_C_UUID => :number,
    Scintilla::SCE_C_PREPROCESSOR => :preprocessor,
    Scintilla::SCE_C_OPERATOR => :operator,
    Scintilla::SCE_C_IDENTIFIER => :default,
    Scintilla::SCE_C_STRINGEOL => :error,
    Scintilla::SCE_C_VERBATIM => :string,
    Scintilla::SCE_C_REGEX => :regexp,
    Scintilla::SCE_C_COMMENTLINEDOC => :documentation,
    Scintilla::SCE_C_WORD2 => :keyword,
    Scintilla::SCE_C_COMMENTDOCKEYWORD => :documentation_markup,
    Scintilla::SCE_C_COMMENTDOCKEYWORDERROR => :error,
    Scintilla::SCE_C_GLOBALCLASS => :type,
    Scintilla::SCE_C_STRINGRAW => :string,
    Scintilla::SCE_C_TRIPLEVERBATIM => :string,
    Scintilla::SCE_C_HASHQUOTEDSTRING => :string,
    Scintilla::SCE_C_PREPROCESSORCOMMENT => :comment,
    Scintilla::SCE_C_PREPROCESSORCOMMENTDOC => :documentation,
    Scintilla::SCE_C_USERLITERAL => :number,
    Scintilla::SCE_C_TASKMARKER => :warning,
    Scintilla::SCE_C_ESCAPESEQUENCE => :escape
  }.freeze

  CPP_LEXER_PROFILE = LexerProfile.new(
    :cpp,
    'cpp',
    C_LIKE_LEXER_STYLES,
    {
      0 => CPP_KEYWORDS,
      2 => CPP_DOCUMENTATION_KEYWORDS,
      5 => C_LIKE_TASK_MARKERS
    },
    {
      'lexer.cpp.track.preprocessor' => '0',
      'lexer.cpp.escape.sequence' => '1'
    }
  )
end
