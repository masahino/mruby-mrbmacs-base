module Mrbmacs
  MARKDOWN_LEXER_PROFILE = LexerProfile.new(
    :markdown,
    'markdown',
    {
      Scintilla::SCE_MARKDOWN_DEFAULT => :default,
      Scintilla::SCE_MARKDOWN_LINE_BEGIN => :default,
      Scintilla::SCE_MARKDOWN_STRONG1 => :markup_emphasis,
      Scintilla::SCE_MARKDOWN_STRONG2 => :markup_emphasis,
      Scintilla::SCE_MARKDOWN_EM1 => :markup_emphasis,
      Scintilla::SCE_MARKDOWN_EM2 => :markup_emphasis,
      Scintilla::SCE_MARKDOWN_HEADER1 => :markup_heading,
      Scintilla::SCE_MARKDOWN_HEADER2 => :markup_heading,
      Scintilla::SCE_MARKDOWN_HEADER3 => :markup_heading,
      Scintilla::SCE_MARKDOWN_HEADER4 => :markup_heading,
      Scintilla::SCE_MARKDOWN_HEADER5 => :markup_heading,
      Scintilla::SCE_MARKDOWN_HEADER6 => :markup_heading,
      Scintilla::SCE_MARKDOWN_PRECHAR => :label,
      Scintilla::SCE_MARKDOWN_ULIST_ITEM => :label,
      Scintilla::SCE_MARKDOWN_OLIST_ITEM => :label,
      Scintilla::SCE_MARKDOWN_BLOCKQUOTE => :string,
      Scintilla::SCE_MARKDOWN_STRIKEOUT => :markup_emphasis,
      Scintilla::SCE_MARKDOWN_HRULE => :comment,
      Scintilla::SCE_MARKDOWN_LINK => :markup_link,
      Scintilla::SCE_MARKDOWN_CODE => :markup_code,
      Scintilla::SCE_MARKDOWN_CODE2 => :markup_code,
      Scintilla::SCE_MARKDOWN_CODEBK => :markup_code
    },
    { 0 => '' },
    {}
  )
end
