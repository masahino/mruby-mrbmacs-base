assert('Mrbmacs::ApplicationGui searches incrementally forward') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'alpha beta alpha'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameGui.new(view, echo_win)
  app = build_gui_application_for_test(frame, buffer)

  app.isearch_forward
  assert_true app.isearch_active?
  echo_win.text = 'alpha'
  app.echo_sci_notify('code' => Scintilla::SCN_MODIFIED)
  assert_equal [0, 5], view.selections.last
  assert_true app.echo_key_press('C-s')
  assert_equal [11, 16], view.selections.last
  assert_true app.echo_key_press('C-s')
  assert_equal [0, 5], view.selections.last
  echo_win.text = ''
  app.echo_sci_notify('code' => Scintilla::SCN_MODIFIED)
  assert_equal 0, view.current_pos
  assert_true app.echo_key_press('Enter')
  assert_false app.isearch_active?
end

assert('Mrbmacs::ApplicationGui searches backward and cancels') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'alpha beta alpha'
  view.current_pos = view.text.bytesize
  view.sci_goto_pos(view.current_pos)
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameGui.new(view, echo_win)
  app = build_gui_application_for_test(frame, buffer)

  app.isearch_backward
  echo_win.text = 'alpha'
  app.echo_sci_notify('code' => Scintilla::SCN_MODIFIED)
  assert_equal [11, 16], view.selections.last
  assert_true app.echo_key_press('C-g')
  assert_equal view.text.bytesize, view.current_pos
  assert_false app.isearch_active?
end

assert('Mrbmacs::ApplicationGui uses byte length for search text') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'aあb'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameGui.new(view, echo_win)
  app = build_gui_application_for_test(frame, buffer)

  app.isearch_forward
  echo_win.text = 'あ'
  app.echo_sci_notify('code' => Scintilla::SCN_MODIFIED)
  assert_equal 'あ'.bytesize, view.search_lengths.last
end

assert('Mrbmacs::ApplicationGui highlights every match while searching') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'alpha beta alpha'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameGui.new(view, echo_win)
  app = build_gui_application_for_test(frame, buffer)

  app.isearch_forward
  echo_win.text = 'alpha'
  app.echo_sci_notify('code' => Scintilla::SCN_MODIFIED)

  assert_true app.search_highlight_active?
  assert_equal [[0, 5], [11, 5]], view.indicator_fills
  # the current match (selected at 0..5) is cleared again so only the
  # selection marks it
  assert_true view.indicator_clears.include?([0, 5])
  assert_equal [0, 5], view.selections.last
  assert_equal '    [isearch 1/2]', app.modeline_search

  app.echo_key_press('C-s')
  assert_equal '    [isearch 2/2]', app.modeline_search

  app.echo_key_press('C-s')
  assert_equal [0, 5], view.selections.last
  assert_equal '    [isearch 1/2]', app.modeline_search

  app.echo_key_press('Enter')
  assert_false app.search_highlight_active?
  assert_equal '', app.modeline_search
end
