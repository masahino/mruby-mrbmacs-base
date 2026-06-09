assert('auto_close extension') do
  app = Mrbmacs::TestSupport::Application.new
  assert_equal 1, app.sci_handler[Scintilla::SCN_CHARADDED].size
  assert_equal 10, app.sci_handler[Scintilla::SCN_CHARADDED].last.priority
end

assert('auto_close: no completion when non-space char ahead') do
  app = Mrbmacs::TestSupport::Application.new
  vw  = app.frame.view_win

  vw.test_return[Scintilla::SCI_GETCHARAT] = 'a'.ord

  before_len = vw.messages.length
  app.call_sci_event('code' => Scintilla::SCN_CHARADDED, 'ch' => '('.ord)

  # 直後に実文字がある場合は、右括弧を追加する SCI_INSERTTEXT が呼ばれないはず
  new_msgs = vw.messages[before_len..-1] || []
  inserted = new_msgs.include?(Scintilla::SCI_INSERTTEXT)

  assert_equal(false, inserted, "should NOT call SCI_INSERTTEXT when a non-space char is ahead")
end
