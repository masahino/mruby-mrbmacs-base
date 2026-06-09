module Mrbmacs
  # Mrbmacs::Mode
  class Mode
    attr_accessor :name, :lexer, :keyword_list, :indent, :use_tab, :tab_indent, :keymap,
                  :start_of_comment, :end_of_comment, :build_command, :use_builtin_formatting

    class << self
      def instance
        @instance ||= new
      end
    end

    def initialize
      @name = 'default'
      @keyword_list = ''
      @style = [:color_default]
      @indent = 2
      @use_tab = false
      @tab_indent = 0
      @lexer = @name
      @keymap = {}
      @start_of_comment = ''
      @end_of_comment = ''
      @build_command = 'make'
      @use_builtin_formatting = true
    end

    def apply_lexer(view_win)
      return if @lexer.nil?

      view_win.sci_set_lexer_language(@name)
    end

    def apply_theme(view_win, theme)
      @style.each_with_index do |style_name, i|
        next if style_name.nil?

        color = theme.font_color[style_name]
        view_win.sci_style_set_fore(i, color[0])   # foreground
        view_win.sci_style_set_back(i, color[1])   # background
        view_win.sci_style_set_italic(i, color[2]) # italic
        view_win.sci_style_set_bold(i, color[3])   # bold
      end
    end

    def config
      # config
    end

    def end_of_block?(_line)
      false
    end

    def get_indent_level(view_win)
      line = view_win.sci_line_from_position(view_win.sci_get_current_pos)
      level = view_win.sci_get_fold_level(line) & Scintilla::SC_FOLDLEVELNUMBERMASK - Scintilla::SC_FOLDLEVELBASE
      cur_line = view_win.sci_get_curline[0]
      level -= 1 if level > 0 && end_of_block?(cur_line) == true
      level
    end

    def get_indent(view_win)
      view_win.sci_get_indent * get_indent_level(view_win)
    end

    def syntax_check(_view_win)
      []
    end

    def get_candidates(_input)
      @keyword_list.tr(' ', @frame.echo_win.sci.autoc_get_separator.chr)
    end

    def get_completion_list(view_win)
      pos = view_win.sci_get_current_pos
      col = view_win.sci_get_column(pos)
      return [0, []] if col <= 0

      line = view_win.sci_line_from_position(pos)
      line_text = view_win.sci_get_line(line).chomp[0..col]
      input = line_text.split(' ').pop
      return [0, []] if input.nil? || input.length <= 0

      candidates = get_candidates(input)
      [input.length, candidates]
    end

    def add_keybind(key_str, command)
      @keymap[key_str] = command
    end

    def on_style_needed(app, notify)
      # "on_style_needed"
    end
  end

  # fundamental mode
  class FundamentalMode < Mode
    def initialize
      super
      @name = 'fundamental'
      @lexer = 'indent'
      @style = [:color_default]
    end
  end
end
