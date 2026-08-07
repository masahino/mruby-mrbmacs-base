module Mrbmacs
  MARKERN_BREAKPOINT = 0
  MARKERN_CURRENT = 1
  MARKERN_VC_ADDED = 2
  MARKERN_VC_MODIFIED = 3
  MARKERN_VC_DELETED = 4
  MARKERMASK_LINE_NUMBER = (1 << MARKERN_BREAKPOINT) |
                           (1 << MARKERN_CURRENT)
  CHANGE_HISTORY_MARKERS = [
    Scintilla::SC_MARKNUM_HISTORY_REVERTED_TO_ORIGIN,
    Scintilla::SC_MARKNUM_HISTORY_SAVED,
    Scintilla::SC_MARKNUM_HISTORY_MODIFIED,
    Scintilla::SC_MARKNUM_HISTORY_REVERTED_TO_MODIFIED
  ]
  MARKERMASK_CHANGE_HISTORY = CHANGE_HISTORY_MARKERS.inject(0) do |mask, marker|
    mask | (1 << marker)
  end

  # base
  class EditWindow
    attr_accessor :sci, :mode_win, :frame, :buffer, :x1, :y1, :x2, :y2, :width, :height

    MARGIN_LINE_NUMBER = 0
    MARGIN_FOLDING = 1
    MARGIN_VC = 2
    MARGIN_CHANGE_HISTORY = 3

    def initialize(frame, buffer, left, top, width, height)
      @frame = frame
      @buffer = buffer
      @x1 = left
      @y1 = top
      @x2 = left + width - 1
      @y2 = top + height - 1
      @width = width
      @height = height
    end

    def init_sci_default
      @sci.sci_set_caret_fore(0xffffff)
      @sci.sci_set_codepage(Scintilla::SC_CP_UTF8)
      @sci.sci_set_mod_event_mask(Scintilla::SC_MOD_INSERTTEXT | Scintilla::SC_MOD_DELETETEXT)
      # @sci.sci_set_caret_style(Scintilla::CARETSTYLE_BLOCK_AFTER |
      # Scintilla::CARETSTYLE_OVERSTRIKE_BLOCK | 32 |
      # Scintilla::CARETSTYLE_BLOCK)
      @sci.sci_autoc_set_max_height(10)
      @sci.sci_autoc_set_separator("\t".ord)
    end

    def init_buffer(buffer)
      @sci.sci_set_docpointer(buffer.docpointer)
      @sci.sci_set_lexer_language(buffer.mode.name)
    end

    def compute_area
    end

    def refresh
    end

    def delete
    end

    def focus_in
      @sci.sci_set_focus(true)
      @sci.refresh
    end

    def focus_out
      @sci.sci_set_focus(false)
      @sci.refresh
    end

    def set_margin
      @sci.sci_set_margin_widthn(MARGIN_LINE_NUMBER,
                                 @sci.sci_text_width(Scintilla::STYLE_LINENUMBER, '_99999'))
      @sci.sci_set_margin_maskn(MARGIN_LINE_NUMBER, MARKERMASK_LINE_NUMBER)
      @sci.sci_set_marginsensitiven(MARGIN_LINE_NUMBER, 1)
      #      @sci.sci_set_margin_widthn(1, 1)
      #      @sci.sci_set_margin_typen(1, 0)
      @sci.sci_set_margin_maskn(MARGIN_FOLDING, Scintilla::SC_MASK_FOLDERS)
      @sci.sci_set_margin_typen(MARGIN_VC, Scintilla::SC_MARGIN_SYMBOL)
      @sci.sci_set_margin_widthn(
        MARGIN_VC,
        @sci.sci_text_width(Scintilla::STYLE_LINENUMBER, '_')
      )
      vc_marker_mask = (1 << MARKERN_VC_ADDED) |
                       (1 << MARKERN_VC_MODIFIED) |
                       (1 << MARKERN_VC_DELETED)
      @sci.sci_set_margin_maskn(MARGIN_VC, vc_marker_mask)
      @sci.sci_set_margin_typen(MARGIN_CHANGE_HISTORY, Scintilla::SC_MARGIN_SYMBOL)
      @sci.sci_set_margin_widthn(
        MARGIN_CHANGE_HISTORY,
        @sci.sci_text_width(Scintilla::STYLE_LINENUMBER, '_')
      )
      @sci.sci_set_margin_maskn(MARGIN_CHANGE_HISTORY, MARKERMASK_CHANGE_HISTORY)
      @sci.sci_set_marginsensitiven(MARGIN_LINE_NUMBER, 1)
      @sci.sci_set_marginsensitiven(MARGIN_FOLDING, 1)
      @sci.sci_set_automatic_fold(Scintilla::SC_AUTOMATICFOLD_CLICK)

      # margin markers for debug
      @sci.sci_marker_define(MARKERN_BREAKPOINT, Scintilla::SC_MARK_CIRCLE)
      @sci.sci_marker_define(MARKERN_CURRENT, Scintilla::SC_MARK_SHORTARROW)
      @sci.sci_marker_define(MARKERN_VC_ADDED, Scintilla::SC_MARK_LEFTRECT)
      @sci.sci_marker_define(MARKERN_VC_MODIFIED, Scintilla::SC_MARK_LEFTRECT)
      @sci.sci_marker_define(MARKERN_VC_DELETED, Scintilla::SC_MARK_LEFTRECT)
      CHANGE_HISTORY_MARKERS.each do |marker|
        @sci.sci_marker_define(marker, Scintilla::SC_MARK_BAR)
      end
    end

    def apply_theme_annotation(theme)
      if theme.font_color[:color_annotation]
        @sci.sci_style_set_fore(theme.annotation_style(:other), theme.font_color[:color_annotation][0])
        @sci.sci_style_set_back(theme.annotation_style(:other), theme.font_color[:color_annotation][1])
      end
      if theme.font_color[:color_annotation_info]
        @sci.sci_style_set_fore(theme.annotation_style(:info), theme.font_color[:color_annotation_info][0])
        @sci.sci_style_set_back(theme.annotation_style(:info), theme.font_color[:color_annotation_info][1])
      end
      if theme.font_color[:color_annotation_warn]
        @sci.sci_style_set_fore(theme.annotation_style(:warn), theme.font_color[:color_annotation_warn][0])
        @sci.sci_style_set_back(theme.annotation_style(:warn), theme.font_color[:color_annotation_warn][1])
      end
      if theme.font_color[:color_annotation_error]
        @sci.sci_style_set_fore(theme.annotation_style(:error), theme.font_color[:color_annotation_error][0])
        @sci.sci_style_set_back(theme.annotation_style(:error), theme.font_color[:color_annotation_error][1])
      end
      @sci.sci_annotation_set_visible(Scintilla::ANNOTATION_INDENTED)
    end

    def apply_theme_marker(theme)
      if theme.font_color[:color_marker_breakpoint]
        @sci.sci_marker_set_fore(Mrbmacs::MARKERN_BREAKPOINT, theme.font_color[:color_marker_breakpoint][0])
        @sci.sci_marker_set_back(Mrbmacs::MARKERN_BREAKPOINT, theme.font_color[:color_marker_breakpoint][1])
      end
      if theme.font_color[:color_marker_current]
        @sci.sci_marker_set_fore(Mrbmacs::MARKERN_CURRENT, theme.font_color[:color_marker_current][0])
        @sci.sci_marker_set_back(Mrbmacs::MARKERN_CURRENT, theme.font_color[:color_marker_current][1])
      end
      {
        MARKERN_VC_ADDED => :color_marker_vc_added,
        MARKERN_VC_MODIFIED => :color_marker_vc_modified,
        MARKERN_VC_DELETED => :color_marker_vc_deleted
      }.each do |marker, color|
        next unless theme.font_color[color]

        @sci.sci_marker_set_fore(marker, theme.font_color[color][0])
        @sci.sci_marker_set_back(marker, theme.font_color[color][1])
      end
      @sci.sci_marker_set_fore(Scintilla::SC_MARKNUM_HISTORY_REVERTED_TO_ORIGIN, 0xBFA040)
      @sci.sci_marker_set_fore(Scintilla::SC_MARKNUM_HISTORY_SAVED, 0x00A000)
      @sci.sci_marker_set_fore(Scintilla::SC_MARKNUM_HISTORY_MODIFIED, 0x0080FF)
      @sci.sci_marker_set_fore(Scintilla::SC_MARKNUM_HISTORY_REVERTED_TO_MODIFIED, 0x00C0A0)
      if theme.font_color[:color_linenumber]
        @sci.sci_marker_set_back(Scintilla::SC_MARKNUM_HISTORY_REVERTED_TO_ORIGIN,
                                 theme.font_color[:color_linenumber][1])
        @sci.sci_marker_set_back(Scintilla::SC_MARKNUM_HISTORY_SAVED,
                                 theme.font_color[:color_linenumber][1])
        @sci.sci_marker_set_back(Scintilla::SC_MARKNUM_HISTORY_MODIFIED,
                                 theme.font_color[:color_linenumber][1])
        @sci.sci_marker_set_back(Scintilla::SC_MARKNUM_HISTORY_REVERTED_TO_MODIFIED,
                                 theme.font_color[:color_linenumber][1])
      end
    end

    def apply_theme_base(theme)
      @sci.sci_style_set_fore(Scintilla::STYLE_DEFAULT, theme.foreground_color)
      @sci.sci_style_set_back(Scintilla::STYLE_DEFAULT, theme.background_color)
      @sci.sci_style_clear_all
      if theme.font_color[:color_brace_highlight]
        @sci.sci_style_set_fore(Scintilla::STYLE_BRACELIGHT,
                                theme.font_color[:color_brace_highlight][0])
        @sci.sci_style_set_back(Scintilla::STYLE_BRACELIGHT,
                                theme.font_color[:color_brace_highlight][1])
      end
      apply_theme_annotation(theme)
      if theme.font_color[:color_linenumber]
        @sci.sci_style_set_fore(Scintilla::STYLE_LINENUMBER, theme.font_color[:color_linenumber][0])
        @sci.sci_style_set_back(Scintilla::STYLE_LINENUMBER, theme.font_color[:color_linenumber][1])
      end
      apply_theme_marker(theme)
      if theme.font_color[:color_caret_line]
        @sci.sci_set_caret_line_visible(true)
        @sci.sci_set_caret_line_back(theme.font_color[:color_caret_line][1])
      end
      if theme.font_color[:color_indent_guide]
        @sci.sci_style_set_fore(Scintilla::STYLE_INDENTGUIDE, theme.font_color[:color_indent_guide][0])
        @sci.sci_style_set_back(Scintilla::STYLE_INDENTGUIDE, theme.font_color[:color_indent_guide][1])
      end
      @sci.sci_set_sel_fore(true, theme.background_color)
      @sci.sci_set_sel_back(true, theme.foreground_color)
    end

    def apply_theme(theme)
      apply_theme_base(theme)
    end

    def apply_mode_settings(mode)
      @sci.sci_set_keywords(0, mode.keyword_list)
      @sci.sci_set_property('fold', '1')
      @sci.sci_set_tab_width(mode.indent)
      @sci.sci_set_use_tabs(mode.use_tab)
      @sci.sci_set_tab_indents(mode.tab_indent)
      @sci.sci_set_back_space_un_indents(true)
      @sci.sci_set_indent(mode.indent)
      @sci.sci_set_wrap_mode(Scintilla::SC_WRAP_CHAR)
    end

    def newline
      case @sci.sci_get_eol_mode
      when 0
        'CRLF'
      when 1
        #        "mac"
        'CR'
      when 2
        #        "unix"
        'LF'
      else
        ''
      end
    end
  end
end
