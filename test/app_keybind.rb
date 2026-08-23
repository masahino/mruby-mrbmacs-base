assert('key_scan') do
  app = Mrbmacs::TestSupport::Application.new
  assert_equal 'beginning_of_line', app.key_scan('C-a')
  assert_equal Scintilla::SCI_WORDLEFT, app.key_scan('M-b')
  assert_equal nil, app.key_scan('C-q')
  app.current_buffer.mode.keymap['C-a'] = 'hoge'
  assert_equal 'hoge', app.key_scan('C-a')
  app.current_buffer.mode.keymap['C-b'] = Scintilla::SCI_LINESCROLLDOWN
  assert_equal 2342, app.key_scan('C-b')
end

assert('effective_keybindings uses the same priority as key_scan') do
  app = Mrbmacs::TestSupport::Application.new
  mode = Mrbmacs::Mode.new
  app.current_buffer.mode = mode
  app.modify_keymap('C-a', 'global_command')
  app.modify_keymap('C-b', 'global_only')
  mode.add_keybind('C-a', 'mode_command')
  mode.add_keybind('M-x', 'extension_command')

  bindings = app.effective_keybindings

  assert_equal 'mode_command', bindings['C-a']
  assert_equal 'global_only', bindings['C-b']
  assert_equal 'extension_command', bindings['M-x']
end
