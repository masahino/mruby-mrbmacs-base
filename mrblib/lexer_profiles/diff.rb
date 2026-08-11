module Mrbmacs
  DIFF_KEYWORDS = ''

  DIFF_LEXER_PROFILE = LexerProfile.new(
    :diff,
    'diff',
    {
      Scintilla::SCE_DIFF_DEFAULT => :default,
      Scintilla::SCE_DIFF_COMMENT => :comment,
      Scintilla::SCE_DIFF_COMMAND => :default,
      Scintilla::SCE_DIFF_HEADER => :markup_heading,
      Scintilla::SCE_DIFF_POSITION => :markup_heading,
      Scintilla::SCE_DIFF_DELETED => :diff_deleted,
      Scintilla::SCE_DIFF_ADDED => :diff_added,
      Scintilla::SCE_DIFF_CHANGED => :diff_changed,
      Scintilla::SCE_DIFF_PATCH_ADD => :diff_added,
      Scintilla::SCE_DIFF_PATCH_DELETE => :diff_deleted,
      Scintilla::SCE_DIFF_REMOVED_PATCH_ADD => :diff_deleted,
      Scintilla::SCE_DIFF_REMOVED_PATCH_DELETE => :diff_deleted
    },
    { 0 => DIFF_KEYWORDS },
    { 'fold.compact' => '1' }
  )
end
