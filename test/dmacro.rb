assert('dmacro_find_rep') do
  app = Mrbmacs::TestSupport::Application.new
  assert_equal [], app.dmacro_find_rep([1, 2, 3])
  assert_equal [3], app.dmacro_find_rep([1, 2, 3, 3])
  assert_equal [1, 2, 3], app.dmacro_find_rep([1, 2, 3, 1, 2, 3])
  assert_equal [1, 2, 3, 3], app.dmacro_find_rep([1, 2, 3, 3, 1, 2, 3, 3])
end
