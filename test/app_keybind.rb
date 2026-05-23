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
