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

assert('delete_other_window') do
  app = Mrbmacs::TestSupport::Application.new()
  # delete_other_window is implemented by each frontend Frame, not by
  # FrameBase, so the base command's contract is to delegate to the frame.
  called = 0
  app.frame.define_singleton_method(:delete_other_window) { called += 1 }
  app.delete_other_window
  assert_equal 1, called
end

assert('enlarge_window leaves a lone window untouched') do
  app = Mrbmacs::TestSupport::Application.new()
  win = app.frame.edit_win
  before = win.y2
  app.enlarge_window
  assert_equal 1, app.frame.edit_win_list.size
  assert_equal before, win.y2
end

assert('enlarge_window grows the active window into the one below') do
  app = Mrbmacs::TestSupport::Application.new()
  app.split_window_vertically
  active, below = app.frame.edit_win_list
  active_y2 = active.y2
  below_y1 = below.y1

  app.enlarge_window

  assert_equal active_y2 + 1, active.y2
  assert_equal below_y1 + 1, below.y1
end

assert('enlarge_window_horizontally leaves a lone window untouched') do
  app = Mrbmacs::TestSupport::Application.new()
  win = app.frame.edit_win
  before = win.x2
  app.enlarge_window_horizontally
  assert_equal 1, app.frame.edit_win_list.size
  assert_equal before, win.x2
end

assert('enlarge_window_horizontally grows the active window into the one right') do
  app = Mrbmacs::TestSupport::Application.new()
  app.split_window_horizontally
  active, right = app.frame.edit_win_list
  active_x2 = active.x2
  right_x1 = right.x1

  app.enlarge_window_horizontally

  assert_equal active_x2 + 1, active.x2
  assert_equal right_x1 + 1, right.x1
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
