assert('Mrbmacs::ApplicationTerminal replaces all occurrences from point') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'one two one'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameTerminal.new(view, echo_win)
  app = build_terminal_application_for_test(frame, buffer)

  app.replace_string('one', '1', false)

  assert_equal '1 two 1', view.text
  assert_equal [:begin, :end], view.undo_actions
end

assert('Mrbmacs::ApplicationTerminal query-replace confirms each match with y') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'one two one'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameTerminal.new(view, echo_win)
  frame.y_or_n_responses = [true, true]
  app = build_terminal_application_for_test(frame, buffer)

  app.query_replace('one', '1')

  assert_equal '1 two 1', view.text
end

assert('Mrbmacs::ApplicationTerminal query-replace quits on the first non-y answer') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'one two one'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameTerminal.new(view, echo_win)
  # ApplicationTerminal's query-replace only supports "y" (replace and
  # continue) or cancel; unlike ApplicationGui there is no "n" (skip this
  # match but keep going) or "!" (replace all remaining).
  frame.y_or_n_responses = [false]
  app = build_terminal_application_for_test(frame, buffer)

  app.query_replace('one', '1')

  assert_equal 'one two one', view.text
  assert_equal 'Quit', frame.last_message
end
