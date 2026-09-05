assert('Mrbmacs::ApplicationTerminal types characters to find a match and accepts with Enter') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'alpha beta alpha'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameTerminal.new(view, echo_win)
  frame.keys = %w[a l p h a Enter]
  app = build_terminal_application_for_test(frame, buffer)

  app.isearch_forward

  assert_equal [0, 5], view.selections.last
  assert_equal '', echo_win.text
end

assert('Mrbmacs::ApplicationTerminal repeats forward search with C-s, then C-g cancels to the origin') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'alpha beta alpha'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameTerminal.new(view, echo_win)
  frame.keys = %w[a l p h a C-s C-g]
  app = build_terminal_application_for_test(frame, buffer)

  app.isearch_forward

  assert_equal [11, 16], view.selections.last
  assert_equal 0, view.current_pos
end

assert('Mrbmacs::ApplicationTerminal wraps a forward search back to the start on C-s') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'alpha beta alpha'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameTerminal.new(view, echo_win)
  # matches ApplicationGui#perform_isearch: a C-s past the last match wraps
  # and finds the first match again immediately, in the same keypress.
  frame.keys = %w[a l p h a C-s C-s Enter]
  app = build_terminal_application_for_test(frame, buffer)

  app.isearch_forward

  assert_equal [0, 5], view.selections.last
end

assert('Mrbmacs::ApplicationTerminal searches backward from the end of the buffer') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'alpha beta alpha'
  view.current_pos = view.text.bytesize
  view.sci_goto_pos(view.current_pos)
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameTerminal.new(view, echo_win)
  frame.keys = %w[a l p h a C-r Enter]
  app = build_terminal_application_for_test(frame, buffer)

  app.isearch_backward

  # starting at the end, the first match found is the closer one (11..16);
  # C-r then steps further back to the first occurrence (0..5)
  assert_equal [0, 5], view.selections.last
end

assert('Mrbmacs::ApplicationTerminal uses byte length for search text') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'aあb'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameTerminal.new(view, echo_win)
  frame.keys = ['あ', 'Enter']
  app = build_terminal_application_for_test(frame, buffer)

  app.isearch_forward

  assert_equal 'あ'.bytesize, view.search_lengths.last
end

assert('Mrbmacs::ApplicationTerminal highlights every match while searching, and clears on accept') do
  buffer = Mrbmacs::Buffer.new('*scratch*')
  view = Mrbmacs::TestSupport::GuiSciView.new
  view.text = 'alpha beta alpha'
  echo_win = Mrbmacs::TestSupport::GuiSciView.new
  frame = Mrbmacs::TestSupport::FrameTerminal.new(view, echo_win)
  frame.keys = %w[a l p h a Enter]
  app = build_terminal_application_for_test(frame, buffer)

  # isearch's loop runs to completion in one call, so there is no way to
  # inspect state mid-search; instead check the cumulative indicator-fill
  # log recorded while typing 'alpha' out, one character at a time.
  app.isearch_forward

  assert_true view.indicator_fills.include?([0, 5])
  assert_true view.indicator_fills.include?([11, 5])
  assert_false app.search_highlight_active?
end
