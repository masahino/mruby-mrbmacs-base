class TestApp
  attr_accessor :frame, :mark_pos
  attr_accessor :current_buffer, :buffer_list, :prev_buffer
  attr_accessor :theme
  attr_accessor :file_encodings, :system_encodings
end

class TestFrame
  attr_accessor :view_win, :echo_win, :tk
end

def setup
  app = TestApp.new
  sci = nil
  test_text = File.open(File.dirname(__FILE__) + "/test-utf8.input").read

  case Scintilla::PLATFORM
  when :CURSES
    Curses::initscr
    sci = Scintilla::ScinTerm.new
  when :GTK
    sci = nil
  else
    sci = nil
  end
  if sci != nil
    sci.sci_set_text(test_text)
  end
  frame = TestFrame.new
  frame.view_win = sci
  app.frame = frame
  app.current_buffer = Mrbmacs::Buffer.new
  app.system_encodings = `iconv -l`.split(' ')
  app
end

assert('set-buffer-file-coding-system') do
  app = setup
  assert_equal("utf-8", app.current_buffer.encoding)
  Mrbmacs::set_buffer_file_coding_system(app, "shift_jis")
  assert_equal("shift_jis", app.current_buffer.encoding)
  Mrbmacs::set_buffer_file_coding_system(app, "hogehoge")
  assert_equal("shift_jis", app.current_buffer.encoding)
end

