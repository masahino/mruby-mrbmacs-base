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

assert('set_margin defines VC markers and margin') do
  app = Mrbmacs::TestSupport::Application.new
  edit_win = Mrbmacs::TestSupport::EditWindow.new(app.frame, app.current_buffer, 0, 0, 0, 0)

  edit_win.set_margin

  assert_equal 5, edit_win.sci.messages.count { |message| message == Scintilla::SCI_MARKERDEFINE }
  assert_include edit_win.sci.messages, Scintilla::SCI_SETMARGINTYPEN
  assert_include edit_win.sci.messages, Scintilla::SCI_SETMARGINMASKN
end

assert('set_margin keeps VC markers out of the line number margin') do
  app = Mrbmacs::TestSupport::Application.new
  edit_win = Mrbmacs::TestSupport::EditWindow.new(app.frame, app.current_buffer, 0, 0, 0, 0)

  edit_win.set_margin

  assert_equal 1, edit_win.sci.messages.count { |message| message == Scintilla::SCI_SETMARGINTYPEN }
  assert_equal 3, edit_win.sci.messages.count { |message| message == Scintilla::SCI_SETMARGINMASKN }
end

assert('apply_theme sets VC marker colors') do
  app = Mrbmacs::TestSupport::Application.new
  edit_win = app.frame.edit_win

  edit_win.apply_theme(app.theme)

  assert_true edit_win.sci.messages.count { |message| message == Scintilla::SCI_MARKERSETFORE } >= 7
  assert_true edit_win.sci.messages.count { |message| message == Scintilla::SCI_MARKERSETBACK } >= 7
end

assert('newline') do
  app = Mrbmacs::TestSupport::Application.new
  edit_win = Mrbmacs::TestSupport::EditWindow.new(app.frame, app.current_buffer, 0, 0, 0, 0)
  assert_equal 'CRLF', edit_win.newline
end
