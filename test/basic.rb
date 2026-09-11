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
  app.frame.view_win.define_singleton_method(:get_clipboard) { 'copied text' }
  app.set_mark
  app.copy_region
  assert_equal(Scintilla::SCI_SETEMPTYSELECTION, app.frame.view_win.messages.pop)
  assert_equal(nil, app.mark_pos)
  assert_equal('copied text', app.clipboard_text)
end

assert('cut-region') do
  app = Mrbmacs::TestSupport::Application.new
  app.frame.view_win.define_singleton_method(:get_clipboard) { 'cut text' }
  app.cut_region
  assert_equal(nil, app.mark_pos)
  # cut all text
  app.set_mark
  app.cut_region
  assert_equal(nil, app.mark_pos)
  assert_equal('cut text', app.clipboard_text)
end

assert('kill-line') do
  app = Mrbmacs::TestSupport::Application.new
  app.frame.view_win.define_singleton_method(:get_clipboard) { 'killed text' }
  app.kill_line
  assert_equal(Scintilla::SCI_DELETERANGE, app.frame.view_win.messages.pop)
  app.frame.view_win.test_return[Scintilla::SCI_GETLINE] = "\n"
  app.kill_line
  assert_equal(Scintilla::SCI_LINECUT, app.frame.view_win.messages.pop)
  assert_equal('killed text', app.clipboard_text)
end

assert('yank') do
  app = Mrbmacs::TestSupport::Application.new
  app.clipboard_text = 'shared text'
  app.yank
  assert_equal('shared text', app.clipboard_text)
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

# A document backed stand-in for the edit view, used by the rectangle
# commands. Those commands only ask Scintilla document based questions
# (SCI_LINEFROMPOSITION / SCI_GETCOLUMN / SCI_FINDCOLUMN) and then edit by byte
# range, so the whole contract can be modelled here and the commands checked by
# the bytes they leave behind rather than by the order of messages.
#
# Columns count characters, as Scintilla does for double byte text. The
# fixtures avoid tabs, which Scintilla would expand to the tab width.
class RectangleTestDoc
  attr_reader :text, :undo_actions, :empty_selections
  attr_accessor :current_pos

  def initialize(text)
    @text = text
    @current_pos = 0
    @undo_actions = []
    @empty_selections = []
  end

  def lines
    @text.split("\n", -1)
  end

  def sci_get_current_pos
    @current_pos
  end

  def sci_position_from_line(line)
    parts = lines
    pos = 0
    line.times { |i| pos += parts[i].bytesize + 1 }
    pos
  end

  def sci_line_from_position(pos)
    parts = lines
    line = 0
    start = 0
    while line < parts.size - 1
      following = start + parts[line].bytesize + 1
      break if pos < following

      start = following
      line += 1
    end
    line
  end

  def sci_get_column(pos)
    start = sci_position_from_line(sci_line_from_position(pos))
    @text.byteslice(start, pos - start).length
  end

  # Byte position of +column+ on +line+, clamped to the end of the line.
  def sci_find_column(line, column)
    text = lines[line].to_s
    column = text.length if column > text.length
    sci_position_from_line(line) + text[0, column].bytesize
  end

  def sci_delete_range(pos, length)
    tail = @text.byteslice(pos + length, @text.bytesize - pos - length)
    @text = @text.byteslice(0, pos) + tail.to_s
  end

  def sci_insert_text(pos, text)
    tail = @text.byteslice(pos, @text.bytesize - pos)
    @text = @text.byteslice(0, pos) + text + tail.to_s
  end

  def sci_begin_undo_action
    @undo_actions.push :begin
  end

  def sci_end_undo_action
    @undo_actions.push :end
  end

  def sci_set_empty_selection(pos)
    @empty_selections.push pos
    @current_pos = pos
  end
end

# Application whose edit view is +text+, with the mark at +mark_pos+ and point
# at +current_pos+.
def setup_rectangle_app(text, mark_pos, current_pos)
  app = Mrbmacs::TestSupport::Application.new
  doc = RectangleTestDoc.new(text)
  doc.current_pos = current_pos
  app.frame.view_win = doc
  app.mark_pos = mark_pos
  app
end

assert('clear-rectangle blanks the marked columns on every line') do
  # Mark at line 0 column 2, point at line 1 column 6.
  app = setup_rectangle_app("Here is a sample file.\nIt has several lines.\n", 2, 29)
  doc = app.frame.view_win

  app.clear_rectangle

  assert_equal("He    s a sample file.\nIt     several lines.\n", doc.text)
  assert_nil(app.mark_pos)
end

assert('delete-rectangle removes the marked columns on every line') do
  app = setup_rectangle_app("Here is a sample file.\nIt has several lines.\n", 2, 29)
  doc = app.frame.view_win

  app.delete_rectangle

  assert_equal("Hes a sample file.\nIt several lines.\n", doc.text)
  assert_nil(app.mark_pos)
end

assert('rectangle commands accept a mark below point') do
  # The same rectangle as above, marked from its bottom right corner.
  app = setup_rectangle_app("Here is a sample file.\nIt has several lines.\n", 29, 2)
  doc = app.frame.view_win

  app.clear_rectangle

  assert_equal("He    s a sample file.\nIt     several lines.\n", doc.text)
end

assert('rectangle commands measure columns in characters, not bytes') do
  # Columns 1...3 of both lines. On the first line that is 6 bytes, on the
  # second 2, so a byte based implementation would cut the wrong text.
  app = setup_rectangle_app("あいうえお\nabcdefg\n", 3, 19)
  doc = app.frame.view_win

  app.clear_rectangle

  assert_equal("あ  えお\na  defg\n", doc.text)
end

assert('delete-rectangle across multibyte text keeps the other columns') do
  app = setup_rectangle_app("あいうえお\nabcdefg\n", 3, 19)
  doc = app.frame.view_win

  app.delete_rectangle

  assert_equal("あえお\nadefg\n", doc.text)
end

assert('rectangle commands edit inside one undo action') do
  app = setup_rectangle_app("Here is a sample file.\nIt has several lines.\n", 2, 29)
  doc = app.frame.view_win

  app.clear_rectangle

  # One group for the whole rectangle, not one per line.
  assert_equal(%i[begin end], doc.undo_actions)
end

assert('rectangle commands leave point at the top left corner') do
  app = setup_rectangle_app("Here is a sample file.\nIt has several lines.\n", 2, 29)
  doc = app.frame.view_win

  app.clear_rectangle

  assert_equal([2], doc.empty_selections)
  assert_equal(2, doc.current_pos)
end

assert('rectangle commands do nothing without a mark') do
  app = setup_rectangle_app("Here is a sample file.\nIt has several lines.\n", nil, 29)
  doc = app.frame.view_win

  app.clear_rectangle
  app.delete_rectangle

  assert_equal("Here is a sample file.\nIt has several lines.\n", doc.text)
  assert_equal([], doc.undo_actions)
  assert_equal([], doc.empty_selections)
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
