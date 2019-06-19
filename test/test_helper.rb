# test module for mruby-mrbmacs-curses
module Mrbmacs
  class TestApp < Application
    def initialize
      @current_buffer = Buffer.new("*scratch*")
      @frame = Mrbmacs::Frame.new(@current_buffer)
      @buffer_list = []
    end
  end

  class Frame
    attr_accessor :view_win, :echo_win, :tk
    attr_accessor :echo_message
    def initialize(buffer)
      @view_win = Scintilla::TestScintilla.new
      @echo_win = Scintilla::TestScintilla.new
    end

    def waitkey(win)
    end

    def strfkey(key)
    end

    def echo_set_prompt(prompt)
    end

    def echo_gets(prompt, text = "", &block)
      "test"
    end

    def echo_puts(text)
      @echo_message = text
    end

    def modeline(app)
    end

    def exit
    end
  end
end

class << Curses
  [
    :initscr, :raw, :curs_set, :newwin, :wbkgd, :wrefresh
    ].each do |name|
    undef_method name
    define_method(name) do |*args|
    end
  end
end

module Scintilla
  class TestScintilla < ScintillaBase
    attr_accessor :pos
    attr_accessor :messages
    attr_accessor :test_return
    def initialize
      @pos = 0
      @messages = []
      @test_return = {}
    end

    def send_message(id, *args)
      @messages.push id
      if @test_return[id] != nil
        return @test_return[id]
      else
        return 0
      end
    end

    def resize_window(height, width)
    end

    def move_window(x, y)
    end

    def refresh
    end

#    def sci_set_docpointer(doc)
#    end

#    def sci_set_lexer_language(lang)
#    end

    def send_key(key, mod_shift, mod_ctrl, mod_alt)
    end

#   def sci_get_current_pos()
#      @pos
#    end

    def sci_get_curline()
      []
    end
  end
end

class TermKey
  attr_accessor :key_buffer
  class Key
    attr_accessor :key_str
    def initialize(key = nil)
      if key != nil
        @code = key.chr
        @type = TermKey::TYPE_UNICODE
        @modifiers = 0
        @key_str = key
      else
        @code = 0
        @type = TermKey::TYPE_UNKNOWN_CSI
        @modifiers = 0
        @key_str = ""
      end
    end

    def modifiers
      @modifiers
    end

    def type
      @type
    end

    def code
      @code
    end

  end

  def initialize(fd, flag)
    @key_buffer = []
  end

  def waitkey
    if @key_buffer.size > 0
      [TermKey::RES_KEY, TermKey::Key.new(@key_buffer.shift)]
    else
      [TermKey::RES_NONE, TermKey::Key.new]
    end
  end

  def strfkey(key, flag)
    key.key_str
  end

  def buffer_remaining
    0
  end

  def buffer_size
    0
  end
end

def exit
end