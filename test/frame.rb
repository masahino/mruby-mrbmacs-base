assert('get_mode_str') do
  app = Mrbmacs::TestSupport::Application.new
  assert_equal '(', app.frame.get_mode_str(app)[0]
end

assert('apply_theme') do
  theme = Mrbmacs::SolarizedDarkTheme.new
  frame = Mrbmacs::TestSupport::Frame.new(nil)
  frame.apply_theme(theme)
  assert_equal(
    [
      Scintilla::SCI_SETSELFORE,
      Scintilla::SCI_SETSELBACK,
      Scintilla::SCI_SETELEMENTCOLOUR,
      Scintilla::SCI_SETELEMENTCOLOUR
    ],
    frame.view_win.messages.last(4)
  )
end
