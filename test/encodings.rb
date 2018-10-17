module Mrbmacs
  class TestApp < Application
    def initialize
    end
  end
end

class TestFrame
  attr_accessor :view_win, :echo_win, :tk
end

def setup
  app = Mrbmacs::TestApp.new
  sci = nil
  test_text = File.open(File.dirname(__FILE__) + "/test-utf8.input").read

  case Scintilla::PLATFORM
  when :CURSES
#    Curses::initscr
#    sci = Scintilla::ScintillaCurses.new
    sci = nil
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
  app.system_encodings = Mrbmacs::get_encoding_list
  app
end

assert('set-buffer-file-coding-system') do
  app = setup
  assert_equal("utf-8", app.current_buffer.encoding)
  app.set_buffer_file_coding_system("shift_jis")
  assert_equal("shift_jis", app.current_buffer.encoding)
  app.set_buffer_file_coding_system("hogehoge")
  assert_equal("shift_jis", app.current_buffer.encoding)
end

