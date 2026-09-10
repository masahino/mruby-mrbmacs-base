assert('dmacro_find_rep') do
  app = Mrbmacs::TestSupport::Application.new
  assert_equal [], app.dmacro_find_rep([1, 2, 3])
  assert_equal [3], app.dmacro_find_rep([1, 2, 3, 3])
  assert_equal [1, 2, 3], app.dmacro_find_rep([1, 2, 3, 1, 2, 3])
  assert_equal [1, 2, 3, 3], app.dmacro_find_rep([1, 2, 3, 3, 1, 2, 3, 3])
end

# Runs dmacro_exec with a known key history.
def setup_dmacro_app(recent_keys)
  app = Mrbmacs::TestSupport::Application.new
  app.instance_variable_set(:@recent_keys, recent_keys)
  win = app.frame.view_win
  win.messages.clear
  win.calls.clear
  app
end

assert('dmacro-exec needs at least two recent keys') do
  app = setup_dmacro_app(['a'])

  app.dmacro_exec

  assert_equal [], app.frame.view_win.messages
end

assert('dmacro-exec replays the repeated key sequence') do
  app = setup_dmacro_app(%w[a b a b C-t])

  app.dmacro_exec

  # 'a' and 'b' are unbound, so they are inserted as text, one byte each.
  assert_equal [[1, 'a'], [1, 'b']], app.frame.view_win.all_args(Scintilla::SCI_ADDTEXT)
end

assert('dmacro-exec stays quiet when C-t repeats with nothing detected') do
  app = setup_dmacro_app(['C-t', 'C-t'])

  app.dmacro_exec

  assert_equal [], app.frame.view_win.messages
end
