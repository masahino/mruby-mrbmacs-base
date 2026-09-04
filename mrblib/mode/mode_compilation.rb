module Mrbmacs
  # compilation mode
  class CompilationMode < Mode
    def initialize
      super
      @name = 'compilation'
      @lexer_profile = COMPILATION_LEXER_PROFILE
      @keymap['Enter'] = 'compilation_open_file'
    end

    def end_of_block?(line)
      if line =~ /^\s*(end|else|fi|done|}).*$/
        true
      else
        false
      end
    end

    def on_style_needed(app, scn)
      start_line = app.frame.view_win.sci_line_from_position(app.frame.view_win.sci_get_end_styled)
      end_pos = scn['position']
      end_line = app.frame.view_win.sci_line_from_position(end_pos)
      for i in start_line..end_line
        pos = app.frame.view_win.sci_position_from_line(i)
        line_length = app.frame.view_win.sci_line_length(i)
        next if line_length == 0

        app.frame.view_win.sci_start_styling(pos, 0)
        line = app.frame.view_win.sci_get_line(i)
        # /foo/bar/baz/hoge.rb:7:7: syntax error, unexpected keyword_end
        #          if line =~ /^(\/.+):(\d+):(\d+): (.+)$/
        if line =~ /^(\/.+):(\d+):(\d+): (.+)$/
          app.frame.view_win.sci_set_styling(Regexp.last_match[1].length, COMPILATION_STYLE_FILE) # file
          app.frame.view_win.sci_set_styling(1, COMPILATION_STYLE_DEFAULT) # :
          app.frame.view_win.sci_set_styling(Regexp.last_match[2].to_s.length, COMPILATION_STYLE_NUMBER) # line
          app.frame.view_win.sci_set_styling(1, COMPILATION_STYLE_DEFAULT) # :
          app.frame.view_win.sci_set_styling(Regexp.last_match[3].to_s.length, COMPILATION_STYLE_NUMBER) # col
          app.frame.view_win.sci_set_styling(2, COMPILATION_STYLE_DEFAULT) # :
          app.frame.view_win.sci_set_styling(Regexp.last_match[4].length, COMPILATION_STYLE_ERROR) # message
        else
          app.frame.view_win.sci_set_styling(line_length, COMPILATION_STYLE_DEFAULT)
        end
      end
    end
  end

  class Application
    def compilation_open_file
      line_str = @frame.view_win.sci_get_curline[0]
      if line_str =~ /^(\/.+):(\d+):(\d+): (.+)$/
        split_window_vertically if @frame.edit_win_list.size == 1
        other_window
        file = Regexp.last_match[1]
        line = Regexp.last_match[2].to_i - 1
        col = Regexp.last_match[3].to_i
        find_file(file)
        pos = @frame.view_win.sci_position_from_line(line) + col
        @frame.view_win.sci_goto_pos(pos)
      end
    end
  end
end
