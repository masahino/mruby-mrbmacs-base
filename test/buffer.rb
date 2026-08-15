def setup_buffers
  app = Mrbmacs::TestSupport::Application.new
  buf1 = Mrbmacs::Buffer.new('/foo/bar/foo.rb')
  app.add_new_buffer(buf1)
  buf2 = Mrbmacs::Buffer.new('/foo/bar/bar.rb')
  app.add_new_buffer(buf2)
  buf3 = Mrbmacs::Buffer.new('/foo/bar/baz.rb')
  app.add_new_buffer(buf3)
  app.current_buffer = buf3
  app
end

assert('Buffer.new') do
  buffer = Mrbmacs::Buffer.new
  assert_kind_of(Mrbmacs::Buffer, buffer)
end

assert('Buffer.new uses Mode.instance by default') do
  buffer = Mrbmacs::Buffer.new
  assert_equal(Mrbmacs::Mode.instance, buffer.mode)
end

assert('buffer mode') do
  buf1 = Mrbmacs::Buffer.new('/foo/bar/baz.r')
  assert_equal('r', buf1.mode.name)
end

assert('Buffer.update_filename') do
  app = Mrbmacs::TestSupport::Application.new
  app.current_buffer.update_filename('/foo/bar/hoge.rb')
  assert_equal('hoge.rb', app.current_buffer.name)
  assert_equal('/foo/bar/hoge.rb', app.current_buffer.filename)
  assert_equal('/foo/bar', app.current_buffer.directory)
  assert_equal('hoge.rb', app.current_buffer.basename)
  assert_equal('ruby', app.current_buffer.mode.name)
end

assert('new buffer name') do
  app = Mrbmacs::TestSupport::Application.new
  buffer1 = Mrbmacs::Buffer.new('/foo/bar/hoge.rb')
  assert_equal('hoge.rb', buffer1.name)
  app.add_new_buffer(buffer1)

  buffer2 = Mrbmacs::Buffer.new('/aaa/bbb/hoge.rb')
  app.add_new_buffer(buffer2)
  assert_equal('hoge.rb<bbb>', app.buffer_list.last.name)

  buffer3 = Mrbmacs::Buffer.new('/ccc/bbb/hoge.rb')
  app.add_new_buffer(buffer3)
  assert_equal('hoge.rb<ccc/bbb>', app.buffer_list.last.name)
end

assert('Buffer.get_buffer_from_name') do
  assert_nil(Mrbmacs.get_buffer_from_name([], 'hoge'))
  buf1 = Mrbmacs::Buffer.new('/foo/bar/hoge.rb')
  buf2 = Mrbmacs::Buffer.new('/foo/bar/huga.rb')
  buffer_list = [buf1, buf2]
  assert_equal(buf2, Mrbmacs.get_buffer_from_name(buffer_list, 'huga.rb'))
end

assert('Buffer.get_buffer_from_path') do
  assert_nil(Mrbmacs.get_buffer_from_path([], 'hoge'))
  buf1 = Mrbmacs::Buffer.new('/foo/bar/hoge.rb')
  buf2 = Mrbmacs::Buffer.new('/foo/bar/huga.rb')
  buffer_list = [buf1, buf2]
  assert_equal(buf2, Mrbmacs.get_buffer_from_path(buffer_list, '/foo/bar/huga.rb'))
end

assert('switch-to-buffer') do
  app = setup_buffers
  app.switch_to_buffer('bar.rb')
  assert_equal('bar.rb', app.current_buffer.name)
  assert_equal('bar.rb', app.buffer_list.last.name)
end

assert('switch-to-buffer (not exist)') do
  app = setup_buffers
  app.switch_to_buffer('xxx')
  assert_equal('baz.rb', app.current_buffer.name)
  assert_equal('baz.rb', app.buffer_list.last.name)
end

assert('kill-buffer (current_buffer)') do
  app = setup_buffers
  bufs = app.buffer_list.size
  app.kill_buffer('baz.rb')
  assert_equal(bufs - 1, app.buffer_list.size)
  assert_equal('bar.rb', app.buffer_list.last.name)
end

assert('kill-buffer displayed in multiple windows') do
  app = setup_buffers
  app.switch_to_buffer('bar.rb')
  target_buffer = app.current_buffer
  app.split_window_vertically

  assert_equal(2, app.frame.edit_win_list.size)
  assert_equal(target_buffer, app.frame.edit_win_list[0].buffer)
  assert_equal(target_buffer, app.frame.edit_win_list[1].buffer)

  app.kill_buffer(target_buffer.name)

  assert_nil(Mrbmacs.get_buffer_from_name(app.buffer_list, target_buffer.name))
  remaining_windows = app.frame.edit_win_list.select { |win| win.buffer == target_buffer }
  assert_equal(0, remaining_windows.size)
end

assert('kill-buffer displayed in a non-current window') do
  app = setup_buffers
  app.switch_to_buffer('bar.rb')
  target_buffer = app.current_buffer
  app.split_window_vertically
  target_window = app.frame.edit_win
  app.other_window
  app.switch_to_buffer('baz.rb')
  current_window = app.frame.edit_win
  current_buffer = app.current_buffer

  app.kill_buffer(target_buffer.name)

  assert_nil(Mrbmacs.get_buffer_from_name(app.buffer_list, target_buffer.name))
  assert_equal(current_window, app.frame.edit_win)
  assert_equal(current_buffer, app.current_buffer)
  assert_equal(current_buffer, current_window.buffer)
  assert_equal(current_buffer, target_window.buffer)
end

assert('cancel killing a modified buffer displayed in a non-current window') do
  app = setup_buffers
  app.switch_to_buffer('bar.rb')
  target_buffer = app.current_buffer
  app.split_window_vertically
  target_window = app.frame.edit_win
  app.other_window
  app.switch_to_buffer('baz.rb')
  current_window = app.frame.edit_win
  current_buffer = app.current_buffer
  target_window.sci.test_return[Scintilla::SCI_GETMODIFY] = 1
  app.frame.define_singleton_method(:y_or_n) { |_prompt| false }

  app.kill_buffer(target_buffer.name)

  assert_equal(target_buffer, Mrbmacs.get_buffer_from_name(app.buffer_list, target_buffer.name))
  assert_equal(target_buffer, target_window.buffer)
  assert_equal(current_window, app.frame.edit_win)
  assert_equal(current_buffer, app.current_buffer)
  assert_equal(current_buffer, current_window.buffer)
end

assert('kill-buffer (not current_buffer)') do
  app = setup_buffers
  bufs = app.buffer_list.size
  app.kill_buffer('foo.rb')
  assert_equal(bufs - 1, app.buffer_list.size)
  assert_equal('baz.rb', app.buffer_list.last.name)
end

assert('kill-buffer (all buffers)') do
  app = setup_buffers
  app.kill_buffer('foo.rb')
  app.kill_buffer('bar.rb')
  app.kill_buffer('baz.rb')
  app.kill_buffer('*scratch*')
  app.kill_buffer('*Messages*')
  assert_equal(2, app.buffer_list.size)
  assert_equal('*scratch*', app.buffer_list.last.name)
  assert_equal('*Messages*', app.buffer_list.first.name)
end

assert('kill-buffer (not exist)') do
  app = setup_buffers
  bufs = app.buffer_list.size
  app.kill_buffer('xxx')
  assert_equal(bufs, app.buffer_list.size)
end

assert('buffer_list') do
  app = Mrbmacs::TestSupport::Application.new
  buf1 = Mrbmacs::Buffer.new('/foo/bar/foo.rb')
  app.add_new_buffer(buf1)
  assert_equal 'foo.rb', app.buffer_list.last.name
  app.add_new_buffer(Mrbmacs::Buffer.new('/bar/foo.rb'))
  assert_equal 'foo.rb<bar>', app.buffer_list.last.name
  assert_equal 'foo.rb<foo/bar>', app.buffer_list[-2].name
end
