assert('DiffMode identifies hunk headers') do
  assert_true Mrbmacs::DiffMode.hunk_header?('@@ -1,2 +1,3 @@ method')
  assert_false Mrbmacs::DiffMode.hunk_header?('diff --git a/file b/file')
  assert_false Mrbmacs::DiffMode.hunk_header?('+text containing @@ markers')
end

assert('DiffMode binds hunk navigation keys') do
  mode = Mrbmacs::DiffMode.new

  assert_equal 'diff_next_hunk', mode.keymap['M-n']
  assert_equal 'diff_previous_hunk', mode.keymap['M-p']
end

assert('diff hunk navigation rejects a non-diff buffer') do
  app = Mrbmacs::TestSupport::Application.new

  app.diff_next_hunk

  assert_equal 'Not in a diff buffer', app.frame.echo_message
end

assert('diff_previous_hunk rejects a non-diff buffer') do
  app = Mrbmacs::TestSupport::Application.new

  app.diff_previous_hunk

  assert_equal 'Not in a diff buffer', app.frame.echo_message
end

# Builds a diff buffer whose lines are known, so hunk lookup can be verified.
def setup_diff_app(current_line)
  app = Mrbmacs::TestSupport::Application.new
  app.current_buffer.mode = Mrbmacs::DiffMode.new
  lines = [
    'diff --git a/file b/file',
    '@@ -1,2 +1,3 @@',
    ' context',
    '@@ -10,2 +10,3 @@',
    ' more context'
  ]
  win = app.frame.view_win
  win.define_singleton_method(:sci_get_line) { |line| lines[line].to_s }
  win.test_return[Scintilla::SCI_LINEFROMPOSITION] = current_line
  app
end

assert('diff_previous_hunk moves to the nearest hunk header above point') do
  app = setup_diff_app(4)
  win = app.frame.view_win
  requested_line = nil
  win.define_singleton_method(:sci_position_from_line) do |line|
    requested_line = line
    300
  end

  app.diff_previous_hunk

  assert_equal 3, requested_line
  assert_equal 300, win.last_args(Scintilla::SCI_GOTOPOS)[0]
end

assert('diff_previous_hunk reports when no hunk precedes point') do
  app = setup_diff_app(1)

  app.diff_previous_hunk

  assert_equal 'No previous hunk', app.frame.echo_message
end
