assert('apply_theme') do
  app = Mrbmacs::TestSupport::Application.new
  edit_win = app.frame.edit_win
  edit_win.apply_theme(app.theme)
  assert_equal(Scintilla::SCI_SETSELBACK, app.frame.view_win.messages.pop)
end

assert('set_marign') do
  app = Mrbmacs::TestSupport::Application.new
  edit_win = Mrbmacs::TestSupport::EditWindow.new(app.frame, app.current_buffer, 0, 0, 0, 0)
  edit_win.set_margin
  assert_equal(Scintilla::SCI_MARKERDEFINE, edit_win.sci.messages.pop)
end

assert('newline') do
  app = Mrbmacs::TestSupport::Application.new
  edit_win = Mrbmacs::TestSupport::EditWindow.new(app.frame, app.current_buffer, 0, 0, 0, 0)
  assert_equal 'CRLF', edit_win.newline
end
