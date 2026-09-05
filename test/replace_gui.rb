assert('Mrbmacs::ApplicationGui replaces all text from point') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'one two one'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameGui.new(view, echo_win)
  app = build_gui_application_for_test(frame, buffer)

  app.start_replace(false, 'one', '1')

  assert_equal '1 two 1', view.text
  assert_equal [:begin, :end], view.undo_actions
  assert_equal 'Replaced 2 occurrences', frame.last_message
end

assert('Mrbmacs::ApplicationGui starts query replace through the query_replace command') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'one two one'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameGui.new(view, echo_win)
  frame.echo_responses = ['one', '1']
  app = build_gui_application_for_test(frame, buffer)

  app.query_replace

  assert_true app.query_replace_active?
  assert_equal [0, 3], view.selections.last
  assert_true app.echo_key_press('q')
end

assert('Mrbmacs::ApplicationGui skips and replaces query matches') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'one two one'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameGui.new(view, echo_win)
  app = build_gui_application_for_test(frame, buffer)

  app.start_replace(true, 'one', '1')
  assert_true app.query_replace_active?
  assert_equal [0, 3], view.selections.last
  assert_true app.echo_key_press('n')
  assert_equal [8, 11], view.selections.last
  assert_true app.echo_key_press('y')

  assert_equal 'one two 1', view.text
  assert_false app.query_replace_active?
  assert_equal 'Replaced 1 occurrence', frame.last_message
end

assert('Mrbmacs::ApplicationGui replaces remaining query matches') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'one one one'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameGui.new(view, echo_win)
  app = build_gui_application_for_test(frame, buffer)

  app.start_replace(true, 'one', '1')
  assert_true app.echo_key_press('!')

  assert_equal '1 1 1', view.text
  assert_false app.query_replace_active?
  assert_equal 'Replaced 3 occurrences', frame.last_message
end

assert('Mrbmacs::ApplicationGui cancels query replace') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'one two one'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameGui.new(view, echo_win)
  app = build_gui_application_for_test(frame, buffer)

  app.start_replace(true, 'one', '1')
  assert_true app.echo_key_press('C-g')

  assert_equal 'one two one', view.text
  assert_false app.query_replace_active?
  assert_equal 'Quit', frame.last_message
end

assert('Mrbmacs::ApplicationGui rejects an empty replacement search') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'one'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameGui.new(view, echo_win)
  app = build_gui_application_for_test(frame, buffer)

  app.start_replace(false, '', 'x')

  assert_equal 'one', view.text
  assert_equal 'Empty search string', frame.last_message
end

assert('Mrbmacs::ApplicationGui uses byte lengths for replacement') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'a'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameGui.new(view, echo_win)
  app = build_gui_application_for_test(frame, buffer)

  app.start_replace(false, 'a', 'あ')

  assert_equal 'あ'.bytesize, view.replacement_lengths.last
end

assert('Mrbmacs::ApplicationGui highlights every match during query replace') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'one two one'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameGui.new(view, echo_win)
  app = build_gui_application_for_test(frame, buffer)

  app.start_replace(true, 'one', '1')

  assert_true app.search_highlight_active?
  assert_true view.indicator_fills.include?([0, 3])
  assert_true view.indicator_fills.include?([8, 3])
  assert_true view.indicator_clears.include?([0, 3]) # current match excluded

  app.echo_key_press('q')
  assert_false app.search_highlight_active?
end
