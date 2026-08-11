assert('apply_theme') do
  app = Mrbmacs::TestSupport::Application.new
  edit_win = app.frame.edit_win
  edit_win.apply_theme(app.theme)
  assert_equal(
    [
      Scintilla::SCI_SETSELFORE,
      Scintilla::SCI_SETSELBACK,
      Scintilla::SCI_SETELEMENTCOLOUR,
      Scintilla::SCI_SETELEMENTCOLOUR
    ],
    app.frame.view_win.messages.last(4)
  )
end

assert('init_buffer only attaches the document') do
  app = Mrbmacs::TestSupport::Application.new
  buffer = app.current_buffer
  calls = []
  view = Object.new
  view.define_singleton_method(:sci_set_docpointer) { |pointer| calls << [:docpointer, pointer] }
  edit_win = Mrbmacs::EditWindow.new(app.frame, buffer, 0, 0, 0, 0)
  edit_win.sci = view

  edit_win.init_buffer(buffer)

  assert_equal [[:docpointer, buffer.docpointer]], calls
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

  assert_equal 9, edit_win.sci.messages.count { |message| message == Scintilla::SCI_MARKERDEFINE }
  assert_include edit_win.sci.messages, Scintilla::SCI_SETMARGINTYPEN
  assert_include edit_win.sci.messages, Scintilla::SCI_SETMARGINMASKN
end

assert('set_margin keeps VC markers out of the line number margin') do
  app = Mrbmacs::TestSupport::Application.new
  edit_win = Mrbmacs::TestSupport::EditWindow.new(app.frame, app.current_buffer, 0, 0, 0, 0)

  edit_win.set_margin

  assert_equal 2, edit_win.sci.messages.count { |message| message == Scintilla::SCI_SETMARGINTYPEN }
  assert_equal 4, edit_win.sci.messages.count { |message| message == Scintilla::SCI_SETMARGINMASKN }
  Mrbmacs::CHANGE_HISTORY_MARKERS.each do |marker|
    assert_equal 0, Mrbmacs::MARKERMASK_LINE_NUMBER & (1 << marker)
    assert_true (Mrbmacs::MARKERMASK_CHANGE_HISTORY & (1 << marker)) != 0
  end
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
