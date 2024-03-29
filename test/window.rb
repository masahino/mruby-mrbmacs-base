require "#{File.dirname(__FILE__)}/test_helper.rb"

assert('apply_theme') do
  app = Mrbmacs::ApplicationTest.new
  edit_win = app.frame.edit_win
  edit_win.apply_theme(app.theme)
  assert_equal(Scintilla::SCI_SETSELBACK, app.frame.view_win.messages.pop)
end

assert('set_marign') do
  edit_win = Mrbmacs::EditWindowTest.new(0, 0, 0, 0, 0, 0)
  edit_win.set_margin
  assert_equal(Scintilla::SCI_MARKERDEFINE, edit_win.sci.messages.pop)
end

assert('newline') do
  edit_win = Mrbmacs::EditWindowTest.new(0, 0, 0, 0, 0, 0)
  assert_equal 'CRLF', edit_win.newline
end
