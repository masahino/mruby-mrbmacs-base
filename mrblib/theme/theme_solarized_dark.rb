module Mrbmacs
  #  COLOR_BASE03
  #  COLOR_BASE02
  #  COLOR_BASE01
  #  COLOR_BASE00
  #  COLOR_BASE0
  #  COLOR_BASE1
  #  COLOR_BASE2
  #  COLOR_BASE3
  #  COLOR_YELLOW
  #  COLOR_ORANGE
  #  COLOR_RED
  #  COLOR_MAGENTA
  #  COLOR_VIOLET
  #  COLOR_BLUE
  #  COLOR_CYAN
  #  COLOR_GREEN

  class SolarizedDarkTheme < SolarizedTheme
    @@theme_name = 'solarized-dark'
    def initialize
      super
      @name = @@theme_name
      @foreground_color = @@base0
      @background_color = @@base03
      @font_color = {
        # [fore, back, italic_flag, bold_flag ]
        # basic colors
        color_default: [@@base0, @@base03, false, false],
        color_builtin: [@@green, @@base03, false, false],
        color_comment: [@@base01, @@base03, true, false],
        color_constant: [@@cyan, @@base03, false, false],
        color_function_name: [@@blue, @@base03, false, false],
        color_keyword: [@@green, @@base03, false, false],
        color_string: [@@cyan, @@base03, false, false],
        color_type: [@@yellow, @@base03, false, true],
        color_variable_name: [@@blue, @@base03, false, false],
        color_warning: [@@red, @@base03, false, true],
        color_preprocessor: [@@orange, @@base03, false, false],
        color_regexp: [@@orange, @@base03, false, false],
        # extra
        color_doc: [@@base01, @@base03, true, false],
        color_doc_string: [@@base01, @@base03, true, false],
        color_color_constant: [@@green, @@base03, false, false],
        color_comment_delimiter: [@@base01, @@base03, true, false],
        color_negation_char: [@@red, @@base03, false, false],
        color_other_type: [@@blue, @@base03, true, false],
        color_regexp_grouping_construct: [@@orange, @@base03, false, false],
        color_special_keyword: [@@red, @@base03, false, false],
        color_exit: [@@red, @@base03, false, false],
        color_other_emphasized: [@@violet, @@base03, true, true],
        color_regexp_grouping_backslash: [@@yellow, @@base03, false, false],
        # additional
        color_brace_highlight: [@background_color, @foreground_color, false, false],
        color_annotation: [@@base3, @@red, true, false],
        color_annotation_info: [@@base3, @@base01, true, false],
        color_annotation_warn: [@@base3, @@yellow, true, false],
        color_annotation_error: [@@base3, @@red, true, false],
        color_linenumber: [@@base0, @background_color, false, false],
        color_margin_vc: [@@base0, @@base02, false, false],
        color_margin_change_history: [@@base0, @@base02, false, false],
        color_margin_folding: [@background_color, @background_color, false, false],
        color_marker_folding: [@background_color, @@base0, false, false],
        color_caret_line: [@foreground_color, @@base02, false, false],
        color_indent_guide: [@@base01, @background_color, false, false],
        color_marker_vc_added: [@@green, @@green, false, false],
        color_marker_vc_modified: [@@yellow, @@yellow, false, false],
        color_marker_vc_deleted: [@@red, @@red, false, false],
        # frame
        color_mode_line: [@@base03, @@base0, false, false],
        color_mode_line_inactive: [@@base0, @@base03, false, false]
      }
    end
  end
end
