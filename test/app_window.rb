assert('split_window_vertically') do
  app = Mrbmacs::TestSupport::Application.new()
  assert_equal 1, app.frame.edit_win_list.size
  app.split_window_vertically
  assert_equal 2, app.frame.edit_win_list.size
end

assert('split_window_horizontally') do
  app = Mrbmacs::TestSupport::Application.new()
  assert_equal 1, app.frame.edit_win_list.size
  app.split_window_horizontally
  assert_equal 2, app.frame.edit_win_list.size
end

assert('delete_window') do
  app = Mrbmacs::TestSupport::Application.new()
  app.split_window_horizontally
  assert_equal 2, app.frame.edit_win_list.size
  app.delete_window
  assert_equal 1, app.frame.edit_win_list.size
end

assert('other_window') do
  app = Mrbmacs::TestSupport::Application.new()
  org_win = app.frame.edit_win
  app.split_window_horizontally
  app.other_window
  new_win = app.frame.edit_win
  assert_equal new_win.object_id, app.frame.edit_win.object_id
  app.other_window
  assert_equal org_win.object_id, app.frame.edit_win.object_id
end
