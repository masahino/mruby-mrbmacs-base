module Mrbmacs
  class SolarizedLightTheme < SolarizedTheme
    @@theme_name = 'solarized-light'
    def initialize
      super
      @name = @@theme_name
      @foreground_color = @@base00
      @background_color = @@base3
      @font_color = {
        #                                italic, bold
        # basic color
        color_default: [@@base00, @@base3, false, false],
        color_builtin: [@@green, @@base3, false, false],
        color_comment: [@@base1, @@base3, true, false],
        color_constant: [@@cyan, @@base3, false, false],
        color_function_name: [@@blue, @@base3, false, false],
        color_keyword: [@@green, @@base3, false, false],
        color_string: [@@cyan, @@base3, false, false],
        color_type: [@@yellow, @@base3, false, false],
        color_variable_name: [@@blue, @@base3, false, false],
        color_warning: [@@red, @@base3, false, true],
        color_preprocessor: [@@orange, @@base3, false, false],
        color_regexp: [@@orange, @@base3, false, false],
        # extra
        color_doc: [@@base1, @@base3, true, false],
        color_doc_string: [@@base1, @@base3, true, false],
        color_color_constant: [@@green, @@base3, false, false],
        color_comment_delimiter: [@@base1, @@base3, true, false],
        color_negation_char: [@@red, @@base3, false, false],
        color_other_type: [@@blue, @@base3, true, false],
        color_regexp_grouping_construct: [@@orange, @@base3, false, false],
        color_special_keyword: [@@red, @@base3, false, false],
        color_exit: [@@red, @@base3, false, false],
        color_other_emphasized: [@@violet, @@base3, true, true],
        color_regexp_grouping_backslash: [@@yellow, @@base3, false, false],
        # additional
        color_brace_highlight: [@background_color, @foreground_color, false, false],
        color_search_match: [@@base2, @background_color, false, false],
        color_annotation: [@@base03, @@red, true, false],
        color_annotation_info: [@@base03, @@base1, true, false],
        color_annotation_warn: [@@base03, @@yellow, true, false],
        color_annotation_error: [@@base03, @@red, true, false],
        color_linenumber: [@@base00, @background_color, false, false],
        color_margin_vc: [@@base00, @@base2, false, false],
        color_margin_change_history: [@@base00, @@base2, false, false],
        color_margin_folding: [@background_color, @background_color, false, false],
        color_marker_folding: [@background_color, @@base00, false, false],
        color_caret_line: [@foreground_color, @@base2, false, false],
        color_indent_guide: [@@base1, @background_color, false, false],
        color_marker_vc_added: [@@green, @@green, false, false],
        color_marker_vc_modified: [@@yellow, @@yellow, false, false],
        color_marker_vc_deleted: [@@red, @@red, false, false],
        # frame
        color_mode_line: [@@base2, @@base1, false, false],
        color_mode_line_inactive: [@@base1, @@base2, false, false]
      }
    end
  end
end
