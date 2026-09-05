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
  frame.keys = %w[y y]
  app = build_terminal_application_for_test(frame, buffer)

  app.query_replace('one', '1')

  assert_equal '1 two 1', view.text
  assert_equal 'Replaced 2 occurrences', frame.last_message
end

assert('Mrbmacs::ApplicationTerminal query-replace skips a match with n') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'one two one'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameTerminal.new(view, echo_win)
  frame.keys = %w[n y]
  app = build_terminal_application_for_test(frame, buffer)

  app.query_replace('one', '1')

  assert_equal 'one two 1', view.text
  assert_equal 'Replaced 1 occurrence', frame.last_message
end

assert('Mrbmacs::ApplicationTerminal query-replace replaces all remaining with !') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'one two one'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameTerminal.new(view, echo_win)
  frame.keys = ['!']
  app = build_terminal_application_for_test(frame, buffer)

  app.query_replace('one', '1')

  assert_equal '1 two 1', view.text
  assert_equal 'Replaced 2 occurrences', frame.last_message
end

assert('Mrbmacs::ApplicationTerminal query-replace quits on C-g without replacing') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'one two one'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameTerminal.new(view, echo_win)
  frame.keys = ['C-g']
  app = build_terminal_application_for_test(frame, buffer)

  app.query_replace('one', '1')

  assert_equal 'one two one', view.text
  assert_equal 'Quit', frame.last_message
end

assert('Mrbmacs::ApplicationTerminal query-replace stops on q without replacing the current match') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'one two one'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameTerminal.new(view, echo_win)
  frame.keys = ['q']
  app = build_terminal_application_for_test(frame, buffer)

  app.query_replace('one', '1')

  assert_equal 'one two one', view.text
  assert_equal 'Replaced 0 occurrences', frame.last_message
end

assert('Mrbmacs::ApplicationTerminal uses byte length for replacement') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'a'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameTerminal.new(view, echo_win)
  app = build_terminal_application_for_test(frame, buffer)

  app.replace_string('a', 'あ', false)

  assert_equal 'あ'.bytesize, view.replacement_lengths.last
end
