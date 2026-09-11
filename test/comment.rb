# Puts +line_text+ under point in +mode+ with a known line geometry, so the
# positions comment_line / uncomment_line compute can be asserted:
#   start of line = SCI_POSITIONFROMLINE + SCI_GETLINEINDENTATION = 10 + 2 = 12
#   end of line   = SCI_GETLINEENDPOSITION                        = 30
def setup_comment_app(mode, line_text)
  app = Mrbmacs::TestSupport::Application.new
  app.current_buffer.mode = mode
  win = app.frame.view_win
  win.test_return[Scintilla::SCI_GETCURRENTPOS] = 0
  win.test_return[Scintilla::SCI_LINEFROMPOSITION] = 7
  win.test_return[Scintilla::SCI_GETLINE] = line_text
  win.test_return[Scintilla::SCI_POSITIONFROMLINE] = 10
  win.test_return[Scintilla::SCI_GETLINEINDENTATION] = 2
  win.test_return[Scintilla::SCI_GETLINEENDPOSITION] = 30
  win.messages.clear
  win.calls.clear
  app
end

assert('comment-line comments an uncommented line') do
  app = setup_comment_app(Mrbmacs::RubyMode.new, '  foo')
  win = app.frame.view_win

  app.comment_line

  assert_equal([[12, '# '], [30, '']], win.all_args(Scintilla::SCI_INSERTTEXT))
  assert_equal(0, win.count_of(Scintilla::SCI_DELETERANGE))
end

assert('comment-line uncomments an already commented line') do
  app = setup_comment_app(Mrbmacs::RubyMode.new, '  # foo')
  win = app.frame.view_win

  app.comment_line

  assert_equal([[12, 2]], win.all_args(Scintilla::SCI_DELETERANGE))
  assert_equal(0, win.count_of(Scintilla::SCI_INSERTTEXT))
end

assert('comment-line removes both delimiters when the mode has a suffix') do
  app = setup_comment_app(Mrbmacs::CppMode.new, '  /* foo */')
  win = app.frame.view_win

  app.comment_line

  # '/* ' at the start of line, ' */' ending at the end of line.
  assert_equal([[12, 3], [27, 3]], win.all_args(Scintilla::SCI_DELETERANGE))
end

assert('comment-line balances the undo action on both branches') do
  ['  foo', '  # foo'].each do |line_text|
    app = setup_comment_app(Mrbmacs::RubyMode.new, line_text)
    win = app.frame.view_win

    app.comment_line

    assert_equal(1, win.count_of(Scintilla::SCI_BEGINUNDOACTION))
    assert_equal(1, win.count_of(Scintilla::SCI_ENDUNDOACTION))
  end
end

assert('uncomment-line removes the comment prefix') do
  app = setup_comment_app(Mrbmacs::RubyMode.new, '  # foo')
  win = app.frame.view_win

  app.uncomment_line

  assert_equal([[12, 2]], win.all_args(Scintilla::SCI_DELETERANGE))
  assert_equal(1, win.count_of(Scintilla::SCI_ENDUNDOACTION))
end

assert('uncomment-line removes the suffix before the prefix') do
  app = setup_comment_app(Mrbmacs::CppMode.new, '  /* foo */')
  win = app.frame.view_win

  app.uncomment_line

  # The trailing delimiter goes first, so the leading one keeps its position.
  assert_equal([[27, 3], [12, 3]], win.all_args(Scintilla::SCI_DELETERANGE))
end

assert('uncomment-line leaves an uncommented line alone') do
  app = setup_comment_app(Mrbmacs::RubyMode.new, '  foo')
  win = app.frame.view_win

  app.uncomment_line

  assert_equal(0, win.count_of(Scintilla::SCI_DELETERANGE))
  assert_equal(0, win.count_of(Scintilla::SCI_INSERTTEXT))
  assert_equal(1, win.count_of(Scintilla::SCI_ENDUNDOACTION))
end
