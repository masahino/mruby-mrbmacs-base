# test module for mruby-mrbmacs-base
$test_echo_gets = {
  call_block: false,
  input_text: 'test',
  output_text: 'test'
}
$test_file_name = 'test'

module Mrbmacs
  module TestSupport
    # Application class for test
    class Application < Mrbmacs::Application
      attr_accessor :mark_pos, :modeline

      def initialize(argv = [])
        super(argv)
      end

      def add_buffer_to_frame(buffer)
        # dummy
      end

      def read_file_name(_prompt, _directory, _default_name = nil)
        $test_file_name
      end

      def init_frame
        @frame = Mrbmacs::TestSupport::Frame.new(@current_buffer)
        @frame.set_buffer_name(@current_buffer.name)
        @current_buffer.docpointer = @frame.view_win.sci_get_docpointer
      end
    end

    # Frame class for test
    class Frame < Mrbmacs::FrameBase
      attr_accessor :view_win, :echo_win, :tk, :echo_message, :edit_win, :mode_win

      def initialize(buffer)
        @echo_win = Scintilla::TestSupport::Scintilla.new
        @edit_win = Mrbmacs::TestSupport::EditWindow.new(self, buffer, 0, 0, 40, 40)
        @view_win = @edit_win.sci
        @edit_win_list = [@edit_win]
        @mode_win = @edit_win.mode_win
      end

      def new_editwin(buffer, x, y, width, height)
        Mrbmacs::TestSupport::EditWindow.new(self, buffer, x, y, width, height)
      end

      def waitkey(win)
      end

      def strfkey(key)
      end

      def echo_set_prompt(prompt)
      end

      def echo_gets(prompt, text = '', &block)
        if $test_echo_gets[:call_block] == true
          list, len = block.call($test_echo_gets[:input_text])
          $test_echo_gets[:completion_list] = list
          $test_echo_gets[:completion_length] = len
          $test_echo_gets[:output_text]
        else
          $test_echo_gets[:output_text]
        end
      end

      def echo_puts(text)
        @echo_message = text
      end

      def y_or_n(_prompt)
        true
      end

      def modeline(app, win = @mode_win)
      end

      def exit
      end
    end

    # EditWindow class for test
    class EditWindow < Mrbmacs::EditWindow
      def initialize(frame, buffer, x1, y1, width, height)
        @sci = Scintilla::TestSupport::Scintilla.new
        @buffer = buffer
        @x1 = x1
        @y1 = y1
        @x2 = x1 + width - 1
        @y2 = y1 + height - 1
        @width = width
        @height = height
      end
    end

    # A Scintilla view stand-in with a real sci_search_in_target /
    # sci_replace_target implementation over an in-memory @text string, so
    # ApplicationGui's isearch/query-replace logic can be exercised with real
    # search behaviour instead of canned per-message return values
    # (Scintilla::TestSupport::Scintilla only supports the latter, and other
    # tests in this suite depend on that). Used for both the edit view and
    # the echo view in search_gui.rb / replace_gui.rb tests.
    class GuiSciView
      attr_accessor :current_pos, :text
      attr_reader :indicator_fills, :indicator_clears
      attr_reader :replacement_lengths, :search_lengths
      attr_reader :selections, :undo_actions

      def initialize
        @current_pos = 0
        @text = ''
        @selection_start = 0
        @selection_end = 0
        @selections = []
        @target_start = 0
        @target_end = 0
        @search_lengths = []
        @replacement_lengths = []
        @indicator_fills = []
        @indicator_clears = []
        @undo_actions = []
      end

      def sci_get_readonly
        false
      end

      def sci_get_current_pos
        @current_pos
      end

      def sci_goto_pos(position)
        @current_pos = position
        @selection_start = position
        @selection_end = position
      end

      def sci_get_selection_start
        @selection_start
      end

      def sci_get_selection_end
        @selection_end
      end

      def sci_set_sel(start_pos, end_pos)
        @selection_start = start_pos
        @selection_end = end_pos
        @current_pos = end_pos
        @selections << [start_pos, end_pos]
      end

      def sci_set_target_start(position)
        @target_start = position
      end

      def sci_set_target_end(position)
        @target_end = position
      end

      def sci_get_target_start
        @target_start
      end

      def sci_get_target_end
        @target_end
      end

      def sci_set_indicator_current(indicator)
        @current_indicator = indicator
      end

      def sci_get_modify
        0
      end

      def sci_get_first_visible_line
        0
      end

      def sci_position_from_line(_line)
        0
      end

      def sci_get_line_end_position(_line)
        @text.bytesize
      end

      def sci_lines_on_screen
        20
      end

      def sci_indicator_fill_range(start_pos, length)
        @indicator_fills << [start_pos, length]
      end

      def sci_indicator_clear_range(start_pos, length)
        @indicator_clears << [start_pos, length]
      end

      def sci_search_in_target(length, search_text)
        @search_lengths << length
        if @target_start <= @target_end
          target = @text.byteslice(@target_start, @target_end - @target_start)
          char_offset = target.index(search_text)
          return -1 if char_offset.nil?

          found = @target_start + target[0...char_offset].bytesize
        else
          target = @text.byteslice(@target_end, @target_start - @target_end)
          char_offset = target.rindex(search_text)
          return -1 if char_offset.nil?

          found = @target_end + target[0...char_offset].bytesize
        end
        @target_start = found
        @target_end = found + search_text.bytesize
        found
      end

      def sci_replace_target(length, replacement_text)
        @replacement_lengths << length
        prefix = @text.byteslice(0, @target_start)
        suffix = @text.byteslice(@target_end, @text.bytesize - @target_end)
        @text = prefix + replacement_text + suffix
        @target_end = @target_start + replacement_text.bytesize
        @selection_start = @target_start
        @selection_end = @target_end
        @current_pos = @target_end
        replacement_text.bytesize
      end

      def sci_begin_undo_action
        @undo_actions << :begin
      end

      def sci_end_undo_action
        @undo_actions << :end
      end

      def sci_clear_all
        @text = ''
      end

      def sci_add_text(_length, text)
        @text += text
      end

      def sci_document_end
      end

      def sci_get_line(_line)
        @text
      end

      def sci_get_length
        @text.bytesize
      end

      def sci_get_text(_length)
        @text
      end

      def sci_grab_focus
      end

      def refresh
      end
    end

    # A minimal FrameBase-shaped double for ApplicationGui's echo-area
    # isearch/query-replace contract (start_isearch, echo_key_mode's Ruby
    # side, …). GuiSciView instances stand in for the edit view and echo
    # view; echo_gets responses are supplied up front via #echo_responses=.
    class FrameGui
      attr_accessor :view_win, :echo_win
      attr_reader :last_message

      def initialize(view_win, echo_win)
        @view_win = view_win
        @echo_win = echo_win
        @echo_responses = []
      end

      def echo_responses=(responses)
        @echo_responses = responses
      end

      def echo_gets(_prompt, _text = '')
        @echo_responses.shift
      end

      def echo_puts(text)
        @last_message = text
      end

      def modeline(_app)
      end

      def start_isearch(_prompt)
      end

      def update_isearch_prompt(_prompt)
      end

      def set_isearch_text(text)
        @echo_win.sci_clear_all
        @echo_win.sci_add_text(text.bytesize, text)
      end

      def finish_isearch
      end

      def start_query_replace(_prompt)
      end

      def finish_query_replace
      end
    end

    # A minimal FrameBase-shaped double for ApplicationTerminal's blocking
    # isearch/replace loops. Keys are supplied up front as plain strings
    # (already in the 'C-s' / 'a' / 'Enter' form ApplicationTerminal's
    # strfkey result takes) via #keys=; waitkey/strfkey just replay them, so
    # there is no need to model TermKey objects. GuiSciView instances stand
    # in for the edit view and echo view.
    class FrameTerminal
      attr_accessor :view_win, :echo_win
      attr_reader :last_message, :last_prompt

      def initialize(view_win, echo_win)
        @view_win = view_win
        @echo_win = echo_win
        @keys = []
        @echo_responses = []
        @y_or_n_responses = []
      end

      def keys=(keys)
        @keys = keys
      end

      def echo_responses=(responses)
        @echo_responses = responses
      end

      def y_or_n_responses=(responses)
        @y_or_n_responses = responses
      end

      def waitkey(_win)
        [0, @keys.shift]
      end

      def strfkey(key)
        key
      end

      def send_key(key, win)
        win.sci_add_text(key.bytesize, key)
      end

      def echo_set_prompt(prompt)
        @last_prompt = prompt
      end

      def echo_gets(_prompt, _text = '')
        @echo_responses.shift
      end

      def echo_puts(text)
        @last_message = text
      end

      def y_or_n(_prompt)
        @y_or_n_responses.shift
      end

      def modeline(_app)
      end
    end
  end
end

def build_gui_application_for_test(frame, buffer)
  app = Mrbmacs::ApplicationGui.allocate
  app.init_instance_variables
  app.instance_variable_set(:@logger, app.init_logfile)
  app.frame = frame
  app.current_buffer = buffer
  app.buffer_list = [buffer]
  app
end

def build_terminal_application_for_test(frame, buffer)
  app = Mrbmacs::ApplicationTerminal.allocate
  app.init_instance_variables
  app.instance_variable_set(:@logger, app.init_logfile)
  app.frame = frame
  app.current_buffer = buffer
  app.buffer_list = [buffer]
  app
end

#class << Curses
#  [
#    :initscr, :raw, :curs_set, :newwin, :wbkgd, :wrefresh
#    ].each do |name|
#    undef_method name
#    define_method(name) do |*args|
#    end
#  end
#end

module Scintilla
  Scintilla::PLATFORM = :TEST

  module TestSupport
    # Scintilla class for test
    class Scintilla < ScintillaBase
      attr_accessor :pos, :messages, :test_return

      def initialize
        @pos = 0
        @messages = []
        @test_return = {}
      end

      def send_message(id, *args)
        @messages.push id
        if @test_return[id] != nil
          @test_return[id]
        else
          0
        end
      end

      def send_message_get_text(_message, length)
        send_message(::Scintilla::SCI_GETTEXT, [length])
      end

      def send_message_get_line(line)
        send_message(::Scintilla::SCI_GETLINE, [line])
      end

      def send_message_get_text(_message, _wparam)
        ''
      end

      def send_message_set_docpointer(id, wparam)
      end

      def send_message_get_docpointer(wparam)
      end

      def resize_window(height, width)
      end

      def move_window(x, y)
      end

      def refresh
      end

      def send_key(key, mod_shift, mod_ctrl, mod_alt)
      end

      def sci_get_curline
        []
      end

      def sci_set_lexer_language(lang)
      end
    end
  end
end

# TermKey class for test
class TermKey
  attr_accessor :key_buffer

  # Key
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
        @key_str = ''
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

  def initialize(_fd, _flag)
    @key_buffer = []
  end

  def waitkey
    if @key_buffer.size > 0
      [TermKey::RES_KEY, TermKey::Key.new(@key_buffer.shift)]
    else
      [TermKey::RES_NONE, TermKey::Key.new]
    end
  end

  def strfkey(key, _flag)
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
  # dummy
end
