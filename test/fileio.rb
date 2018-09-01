module Mrbmacs
  class TestApp < Application
    def initialize
    end
  end
end

class TestFrame
  attr_accessor :view_win, :echo_win, :tk
  def echo_puts(msg)
    $stderr.puts msg
  end

  def set_buffer_name(name)
  end

  def modeline(app)
  end
end

def setup
  app = Mrbmacs::TestApp.new
  sci = nil
  test_text = File.open(File.dirname(__FILE__) + "/test.input").read

  case Scintilla::PLATFORM
  when :CURSES
    Curses::initscr
    sci = Scintilla::ScintillaCurses.new
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
  app.buffer_list = [app.current_buffer]
  app.file_encodings = []
  app
end

assert('insert-file 1') do
  app = setup
  win = app.frame.view_win
  org_text = win.sci_get_text(win.sci_get_length + 1)
  test_file = File.dirname(__FILE__) + "/test.input"
  app.insert_file(test_file)
  text = win.sci_get_text(win.sci_get_length + 1)
  assert_equal(org_text + org_text, text)
end

assert('insert-file 2') do
  app = setup
  win = app.frame.view_win
  org_text = win.sci_get_text(win.sci_get_length + 1)
  test_file = File.dirname(__FILE__) + "/test.input"
  win.sci_set_current_pos(5)
  app.insert_file(test_file)
  text = win.sci_get_text(win.sci_get_length + 1)
  assert_equal(org_text[0..4] + org_text + org_text[5..-1], text)
end

assert('write-file') do
  app = setup
  win = app.frame.view_win
  org_text = win.sci_get_text(win.sci_get_length + 1)
  test_file = File.dirname(__FILE__) + "/test.output"
  app.write_file(test_file)
  test_text = File.open(test_file).read
  assert_equal(org_text, test_text)
end

assert('eolmode') do
  app = setup
  test_file = File.dirname(__FILE__) + "/test-utf8.input"
  app.find_file(test_file)
  assert_equal(Scintilla::SC_EOL_LF, app.frame.view_win.sci_get_eolmode)
  test_file = File.dirname(__FILE__) + "/test-utf8-dos.input"
  app.find_file(test_file)
  assert_equal(Scintilla::SC_EOL_CRLF, app.frame.view_win.sci_get_eolmode)
  test_file = File.dirname(__FILE__) + "/test-utf8-mac.input"
  app.find_file(test_file)
  assert_equal(Scintilla::SC_EOL_CR, app.frame.view_win.sci_get_eolmode)
end
