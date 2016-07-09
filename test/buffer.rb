module Mrbmacs
  class TestApp < Application
    def initialize
    end
  end
end

class TestFrame
  attr_accessor :view_win, :echo_win, :tk
end

class TestTheme
  attr_accessor :style_list, :foreground_color, :background_color
  def initialize
    @foreground_color = nil
    @background_color = nil
    @style_list= {}
  end
end

def setup
  app = Mrbmacs::TestApp.new
  sci = nil
  test_text = File.open(File.dirname(__FILE__) + "/test.input").read

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
  app.current_buffer.name = "test"
  app.current_buffer.docpointer = frame.view_win.sci_get_docpointer
  app.prev_buffer = app.current_buffer
  app.buffer_list = [app.current_buffer]
  app.theme = TestTheme.new
  app
end

assert('switch-to-buffer') do
  app = setup
  assert_equal("test", app.current_buffer.name)
  assert_equal(0, app.current_buffer.pos)
  app.frame.view_win.sci_set_current_pos(10)
  
  new_buffer = Mrbmacs::Buffer.new("new")
  app.buffer_list.push(new_buffer)
  app.switch_to_buffer("new")
  app.current_buffer.docpointer = app.frame.view_win.sci_get_docpointer

  assert_equal("new", app.current_buffer.name)
  assert_equal(0, app.current_buffer.pos)
  assert_equal(2, app.buffer_list.size)
  app.switch_to_buffer("test")
  assert_equal("test", app.current_buffer.name)
  assert_equal(10, app.current_buffer.pos)
end

assert('new buffer name') do
  app = setup
  buffer = Mrbmacs::Buffer.new("/foo/bar/hoge.rb", [])
  assert_equal("hoge.rb", buffer.name)

  buffer = Mrbmacs::Buffer.new("/foo/bar/hoge.rb", ["hoge.rb"])
  assert_equal("hoge.rb<bar>", buffer.name)

  buffer = Mrbmacs::Buffer.new("/foo/bar/hoge.rb", ["hoge.rb", "hoge.rb<bar>"])
  assert_equal("hoge.rb<foo/bar>", buffer.name)
end