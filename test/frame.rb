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
      Scintilla::SCI_SETELEMENTCOLOUR,
      Scintilla::SCI_INDICSETSTYLE,
      Scintilla::SCI_INDICSETFORE,
      Scintilla::SCI_INDICSETALPHA,
      Scintilla::SCI_INDICSETOUTLINEALPHA
    ],
    frame.view_win.messages.last(8)
  )
  assert_equal(
    [
      Scintilla::SCI_STYLESETFORE,
      Scintilla::SCI_STYLESETBACK,
      Scintilla::SCI_STYLECLEARALL,
      Scintilla::SCI_STYLESETFORE,
      Scintilla::SCI_STYLESETBACK,
      Scintilla::SCI_SETCARETFORE
    ],
    frame.echo_win.messages.last(6)
  )
end
