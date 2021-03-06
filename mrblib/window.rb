# coding: utf-8
module Mrbmacs
  class EditWindow
    attr_accessor :sci, :mode_win, :frame
    attr_accessor :command_list
    attr_accessor :buffer
    attr_accessor :x1, :y1, :x2, :y2, :width, :height
    def initialize(frame, buffer, x1, y1, width, height)
      $stderr.puts "not yet implemented"
    end

    def set_buffer(buffer)
      @sci.sci_set_docpointer(buffer.docpointer)
      @sci.sci_set_lexer_language(buffer.mode.name)
#      buffer.mode.set_style(view_win, @theme)
    end

    def compute_area
    end

    def refresh
    end

    def delete
    end

    def focus_in()
      @sci.sci_set_focus(true)
      @sci.refresh
    end

    def focus_out()
      @sci.sci_set_focus(false)
      @sci.refresh
    end

    def set_margin()
      @sci.sci_set_margin_widthn(0, @sci.sci_text_width(Scintilla::STYLE_LINENUMBER, "_99999"))
#      @sci.sci_set_margin_widthn(1, 1)
#      @sci.sci_set_margin_typen(1, 0)
      @sci.sci_set_margin_maskn(1, Scintilla::SC_MASK_FOLDERS)
      @sci.sci_set_marginsensitiven(1, 1)
      @sci.sci_set_automatic_fold(Scintilla::SC_AUTOMATICFOLD_CLICK)
    end

    def set_theme_base(theme)
      @sci.sci_style_clear_all
      @sci.sci_style_set_fore(Scintilla::STYLE_DEFAULT, theme.foreground_color)
      @sci.sci_style_set_back(Scintilla::STYLE_DEFAULT, theme.background_color)
      if theme.font_color[:color_brace_highlight]
        @sci.sci_style_set_fore(Scintilla::STYLE_BRACELIGHT,
          theme.font_color[:color_brace_highlight][0])
        @sci.sci_style_set_back(Scintilla::STYLE_BRACELIGHT,
          theme.font_color[:color_brace_highlight][1])
      end
      if theme.font_color[:color_annotation]
        @sci.sci_style_set_fore(254, theme.font_color[:color_annotation][0])
        @sci.sci_style_set_back(254, theme.font_color[:color_annotation][1])
        @sci.sci_annotation_set_visible(Scintilla::ANNOTATION_BOXED)
      end
      if theme.font_color[:color_linenumber]
        @sci.sci_style_set_fore(Scintilla::STYLE_LINENUMBER,
          theme.font_color[:color_linenumber][0])
        sci.sci_style_set_back(Scintilla::STYLE_LINENUMBER,
          theme.font_color[:color_linenumber][1])
      end
      if theme.font_color[:color_caret_line]
        @sci.sci_set_caret_line_visible(true)
        @sci.sci_set_caret_line_back(theme.font_color[:color_caret_line][1])
      end
      if theme.font_color[:color_indent_guide]
        @sci.sci_style_set_fore(Scintilla::STYLE_INDENTGUIDE,
          theme.font_color[:color_indent_guide][0])
        @sci.sci_style_set_back(Scintilla::STYLE_INDENTGUIDE,
          theme.font_color[:color_indent_guide][1])
      end
      @sci.sci_set_sel_fore(true, theme.background_color)
      @sci.sci_set_sel_back(true, theme.foreground_color)
    end

    def set_theme(theme)
      set_theme_base(theme)
    end

    def newline()
      case @sci.sci_get_eol_mode
      when 0
        "CRLF"
      when 1
#        "mac"
        "CR"
      when 2
#        "unix"
        "LF"
      else
        ""
      end
    end
  end
end
