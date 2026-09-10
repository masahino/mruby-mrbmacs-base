assert('set-mark') do
  app = Mrbmacs::TestSupport::Application.new
  assert_equal(nil, app.mark_pos)
  app.set_mark
  assert_equal(0, app.mark_pos)
  app.copy_region
  assert_equal(nil, app.mark_pos)
end

assert('copy-region') do
  app = Mrbmacs::TestSupport::Application.new
  app.set_mark
  app.copy_region
  assert_equal(Scintilla::SCI_SETEMPTYSELECTION, app.frame.view_win.messages.pop)
  assert_equal(nil, app.mark_pos)
end

assert('cut-region') do
  app = Mrbmacs::TestSupport::Application.new
  app.cut_region
  assert_equal(nil, app.mark_pos)
  # cut all text
  app.set_mark
  app.cut_region
  assert_equal(nil, app.mark_pos)
end

assert('kill-line') do
  app = Mrbmacs::TestSupport::Application.new
  app.kill_line
  assert_equal(Scintilla::SCI_DELETERANGE, app.frame.view_win.messages.pop)
  app.frame.view_win.test_return[Scintilla::SCI_GETLINE] = "\n"
  app.kill_line
  assert_equal(Scintilla::SCI_LINECUT, app.frame.view_win.messages.pop)
end

assert('yank') do
  app = Mrbmacs::TestSupport::Application.new
  app.yank
  assert_equal(Scintilla::SCI_PASTE, app.frame.view_win.messages.pop)
end

assert('beginning-of-line') do
  app = Mrbmacs::TestSupport::Application.new
  app.beginning_of_line
  assert_equal(Scintilla::SCI_HOME, app.frame.view_win.messages.pop)
end

assert('end-of-line') do
  app = Mrbmacs::TestSupport::Application.new
  app.end_of_line
  assert_equal(Scintilla::SCI_LINEEND, app.frame.view_win.messages.pop)
end

assert('beginning-of-buffer') do
  app = Mrbmacs::TestSupport::Application.new
  app.beginning_of_buffer
  assert_equal(Scintilla::SCI_DOCUMENTSTART, app.frame.view_win.messages.pop)
end

assert('end-of-buffer') do
  app = Mrbmacs::TestSupport::Application.new
  app.end_of_buffer
  assert_equal(Scintilla::SCI_DOCUMENTEND, app.frame.view_win.messages.pop)
end

assert('newline') do
  app = Mrbmacs::TestSupport::Application.new
  win = app.frame.view_win
  win.test_return[Scintilla::SCI_AUTOCACTIVE] = 0
  app.newline
  assert_equal(Scintilla::SCI_NEWLINE, win.messages.pop)
end

assert('keyboard-quit 1') do
  app = Mrbmacs::TestSupport::Application.new
  app.set_mark
  assert_equal(0, app.mark_pos)
  app.keyboard_quit
  assert_equal(nil, app.mark_pos)
end

assert('keyboard-quit 2') do
  app = Mrbmacs::TestSupport::Application.new
  app.keyboard_quit
  assert_nil(app.mark_pos)
end

assert('isearch-forward') do
  assert_equal(true, Mrbmacs::Application.instance_methods.include?(:isearch_forward))
end

assert('isearch-backward') do
  assert_equal(true, Mrbmacs::Application.instance_methods.include?(:isearch_backward))
end

assert('indent') do
  app = Mrbmacs::TestSupport::Application.new
  win = app.frame.view_win
  win.test_return[Scintilla::SCI_AUTOCACTIVE] = 1
  app.indent
  assert_equal(Scintilla::SCI_AUTOCCOMPLETE, app.frame.view_win.messages.pop)
  win.test_return[Scintilla::SCI_AUTOCACTIVE] = 0
  app.indent
  assert_equal(Scintilla::SCI_GETCOLUMN, app.frame.view_win.messages.pop)
end

assert('sava-buffers-kill-terminal') do
  app = Mrbmacs::TestSupport::Application.new
  assert_nil(app.save_buffers_kill_terminal)
end

assert('prepare-to-exit stops when closing a buffer is cancelled') do
  app = Mrbmacs::TestSupport::Application.new
  app.add_new_buffer(Mrbmacs::Buffer.new('/foo/bar/foo.rb'))
  app.define_singleton_method(:process_buffer_close) do |_buffer, _allow_all|
    :cancelled
  end

  assert_false app.prepare_to_exit
end

assert('prepare-to-exit discards all remaining normal buffers') do
  app = Mrbmacs::TestSupport::Application.new
  app.add_new_buffer(Mrbmacs::Buffer.new('/foo/bar/foo.rb'))
  app.add_new_buffer(Mrbmacs::Buffer.new('/foo/bar/bar.rb'))
  app.add_new_buffer(Mrbmacs::Buffer.new('/foo/bar/baz.rb'))
  closed = []
  calls = 0
  app.define_singleton_method(:process_buffer_close) do |_buffer, allow_all|
    calls += 1
    assert_true allow_all
    :discard_all
  end
  app.define_singleton_method(:close_buffer) do |buffer|
    closed << buffer.name
    @buffer_list.delete(buffer)
    :closed
  end

  assert_true app.prepare_to_exit
  assert_equal 1, calls
  assert_equal ['foo.rb', 'bar.rb', 'baz.rb'], closed
  assert_equal ['*Messages*', '*scratch*'], app.buffer_list.map(&:name)
end

assert('clear-rectangle') do
  app = Mrbmacs::TestSupport::Application.new

  # Without a mark the command returns before touching the view.
  app.mark_pos = nil
  app.frame.view_win.messages.clear
  app.clear_rectangle
  assert_equal([], app.frame.view_win.messages)

  # With a mark it replaces the rectangle and clears the mark.
  app.mark_pos = 1
  app.clear_rectangle
  assert_equal(Scintilla::SCI_REPLACERECTANGULAR, app.frame.view_win.messages.pop)
  assert_nil(app.mark_pos)
end

assert('delete-rectangle') do
  app = Mrbmacs::TestSupport::Application.new

  # Without a mark the command returns before touching the view.
  app.mark_pos = nil
  app.frame.view_win.messages.clear
  app.delete_rectangle
  assert_equal([], app.frame.view_win.messages)

  # With a mark it deletes the rectangle and clears the mark.
  app.mark_pos = 1
  app.delete_rectangle
  assert_equal(Scintilla::SCI_REPLACESEL, app.frame.view_win.messages.pop)
  assert_nil(app.mark_pos)
end

assert('recenter') do
  app = Mrbmacs::TestSupport::Application.new
  app.recenter
  assert_equal(Scintilla::SCI_VERTICALCENTRECARET, app.frame.view_win.messages.pop)
end

# Places +word+ under point, ending at +word_end+, for the case commands.
def setup_word_app(word, word_end)
  app = Mrbmacs::TestSupport::Application.new
  win = app.frame.view_win
  win.test_return[Scintilla::SCI_GETCURRENTPOS] = 0
  win.test_return[Scintilla::SCI_GETLENGTH] = 100
  win.test_return[Scintilla::SCI_WORDENDPOSITION] = word_end
  win.test_return[Scintilla::SCI_GETTEXTRANGE] = word
  win.messages.clear
  win.calls.clear
  app
end

assert('downcase-word lowercases the word after point') do
  app = setup_word_app('HELLO', 5)
  win = app.frame.view_win

  app.downcase_word

  assert_equal([0, 5], win.last_args(Scintilla::SCI_GETTEXTRANGE))
  assert_equal([0, 5], win.last_args(Scintilla::SCI_DELETERANGE))
  assert_equal([5, 'hello'], win.last_args(Scintilla::SCI_ADDTEXT))
end

assert('upcase-word uppercases the word after point') do
  app = setup_word_app('hello', 5)
  win = app.frame.view_win

  app.upcase_word

  assert_equal([0, 5], win.last_args(Scintilla::SCI_GETTEXTRANGE))
  assert_equal([0, 5], win.last_args(Scintilla::SCI_DELETERANGE))
  assert_equal([5, 'HELLO'], win.last_args(Scintilla::SCI_ADDTEXT))
end

assert('word case commands measure the word in bytes') do
  # Scintilla positions and lengths are byte based. With MRB_UTF8_STRING
  # enabled 'あいう' is 3 characters but always 9 bytes, so the commands must
  # report 9 here regardless of how the build counts characters.
  app = setup_word_app('あいう', 9)
  win = app.frame.view_win

  app.downcase_word

  assert_equal(9, win.last_args(Scintilla::SCI_DELETERANGE)[1])
  assert_equal(9, win.last_args(Scintilla::SCI_ADDTEXT)[0])
end

assert('word case commands do nothing without a word after point') do
  app = setup_word_app('', 0)
  win = app.frame.view_win

  app.downcase_word
  app.upcase_word

  assert_equal(0, win.count_of(Scintilla::SCI_DELETERANGE))
  assert_equal(0, win.count_of(Scintilla::SCI_ADDTEXT))
end
