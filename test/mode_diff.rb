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
