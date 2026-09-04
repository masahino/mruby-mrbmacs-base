module Mrbmacs
  # grep
  class GrepMode < Mode
    attr_accessor :pattern

    def initialize
      super
      @name = 'grep'
      @lexer_profile = GREP_LEXER_PROFILE
      @keymap['Enter'] = 'grep_open_file'
      @pattern = ''
    end

    def end_of_block?(_line)
      false
    end

    def on_style_needed(app, scn)
      start_line = app.frame.view_win.sci_line_from_position(app.frame.view_win.sci_get_end_styled)

      end_pos = scn['position']
      end_line = app.frame.view_win.sci_line_from_position(end_pos)
      for i in start_line..end_line
        pos = app.frame.view_win.sci_position_from_line(i)
        line_length = app.frame.view_win.sci_line_length(i)
        pattern = app.current_buffer.mode.pattern
        next if line_length == 0

        app.frame.view_win.sci_start_styling(pos, 0)
        line = app.frame.view_win.sci_get_line(i)
        # /foo/bar/baz/hoge.rb:7: syntax error, unexpected keyword_end
        if line =~ /^(.+):(\d+):(.*)(#{pattern})(.*)$/
          app.frame.view_win.sci_set_styling(Regexp.last_match[1].length, GREP_STYLE_FILE) # file
          app.frame.view_win.sci_set_styling(1, GREP_STYLE_DEFAULT) # :
          app.frame.view_win.sci_set_styling(Regexp.last_match[2].to_s.length, GREP_STYLE_NUMBER) # line
          app.frame.view_win.sci_set_styling(1, GREP_STYLE_DEFAULT) # :
          app.frame.view_win.sci_set_styling(Regexp.last_match[3].length, GREP_STYLE_DEFAULT) # normal text
          app.frame.view_win.sci_set_styling(Regexp.last_match[4].length, GREP_STYLE_PATTERN) # match pattern
          app.frame.view_win.sci_set_styling(Regexp.last_match[5].length, GREP_STYLE_DEFAULT) # match pattern
        else
          app.frame.view_win.sci_set_styling(line_length, GREP_STYLE_DEFAULT)
        end
      end
    end

    def self.extract_pattern(command_str)
      command_str.split(/\s+/)[1..-2].each do |str|
        return str if str[0] != '-'
      end
      ''
    end
  end

  class Application
    def grep_open_file
      line_str = @frame.view_win.sci_get_curline[0]
      if line_str =~ /^(.+):(\d+):(.+)$/
        split_window_vertically if @frame.edit_win_list.size == 1
        other_window
        file = Regexp.last_match[1]
        line = Regexp.last_match[2].to_i - 1
        find_file(file)
        pos = @frame.view_win.sci_position_from_line(line)
        @frame.view_win.sci_goto_pos(pos)
      end
    end
  end
end
