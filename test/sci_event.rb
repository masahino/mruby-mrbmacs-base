assert('add event') do
  app = Mrbmacs::TestSupport::Application.new
  $test_data = 0
  app.add_sci_event(Scintilla::SCN_MODIFIED) do |app, scn|
    $test_data = 1
  end
  assert_equal(100, app.sci_handler[Scintilla::SCN_MODIFIED].last.priority)
  app.call_sci_event({'code' => Scintilla::SCN_MODIFIED})
  assert_equal(1, $test_data)

  app.add_sci_event(Scintilla::SCN_MODIFIED) do |app, scn|
    $test_data = 2
  end
  assert_equal(101, app.sci_handler[Scintilla::SCN_MODIFIED].last.priority)
  app.call_sci_event({'code' => Scintilla::SCN_MODIFIED})
  assert_equal(2, $test_data)
end

assert('add event with priority') do
  app = Mrbmacs::TestSupport::Application.new
  $test_data = 0
  app.add_sci_event(Scintilla::SCN_ZOOM, 10) do |app, scn|
    $test_data = 1
  end
  assert_equal(10, app.sci_handler[Scintilla::SCN_ZOOM].first.priority)
  app.call_sci_event({'code' => Scintilla::SCN_ZOOM})
  assert_equal(1, $test_data)

  app.add_sci_event(Scintilla::SCN_ZOOM, 1) do |app, scn|
    $test_data = 2
  end
  assert_equal(1, app.sci_handler[Scintilla::SCN_ZOOM].first.priority)
  app.call_sci_event({'code' => Scintilla::SCN_ZOOM})
  assert_equal(1, $test_data)
end
