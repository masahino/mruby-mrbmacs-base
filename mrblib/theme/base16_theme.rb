module Mrbmacs
  # Base16Theme
  class Base16Theme < Theme
    @@base00 = 0x181818
    @@base01 = 0x282828
    @@base02 = 0x383838
    @@base03 = 0x585858
    @@base04 = 0xb8b8b8
    @@base05 = 0xd8d8d8
    @@base06 = 0xe8e8e8
    @@base07 = 0xf8f8f8
    @@base08 = 0x4246ab
    @@base09 = 0x5696dc
    @@base0A = 0x88caf7
    @@base0B = 0x6cb5a1
    @@base0C = 0xb9c186
    @@base0D = 0xc2af7c
    @@base0E = 0xaf8bba
    @@base0F = 0x4669a1

    def initialize
      if respond_to?(:set_pallete)
        set_pallete
      end
      @name = nil
      @foreground_color = @@base05
      @background_color = @@base00
      @font_color = {
        # [fore, back, italic_flag, bold_flag ]
        # basic colors
        color_default: [@@base05, @background_color, false, false],
        color_builtin: [@@base0E, @background_color, false, false],
        color_comment: [@@base03, @background_color, true, false],
        color_constant: [@@base09, @background_color, false, false],
        color_function_name: [@@base0D, @background_color, false, false],
        color_keyword: [@@base0E, @background_color, false, false],
        color_string: [@@base0B, @background_color, false, false],
        color_type: [@@base0A, @background_color, false, true],
        color_variable_name: [@@base08, @background_color, false, false],
        color_warning: [@@base08, @background_color, false, true],
        color_regexp: [@@base0C, @background_color, false, false],
        color_preprocessor: [@@base0D, @background_color, false, false],
        # extra
        color_doc: [@@base0B, @background_color, true, false],
        color_doc_string: [@@base0B, @background_color, true, false],
        color_color_constant: [@@base09, @background_color, false, false],
        color_comment_delimiter: [@@base03, @background_color, true, false],
        color_negation_char: [@@base0B, @background_color, false, false],
        color_other_type: [@@base05, @background_color, true, false],
        color_regexp_grouping_construct: [@@base0E, @background_color, false, false],
        color_special_keyword: [@@base0E, @background_color, false, false],
        color_exit: [@@base0E, @background_color, false, false],
        color_other_emphasized: [@@base05, @background_color, true, true],
        color_regexp_grouping_backslash: [@@base05, @background_color, false, false],
        # additional
        color_brace_highlight: [@@base08, @@base04, false, false],
        color_annotation: [@@base05, @@base08, true, false],
        color_annotation_info: [@@base06, @@base03, true, false],
        color_annotation_warn: [@@base06, @@base0F, true, false],
        color_annotation_error: [@@base06, @@base08, true, false],
        color_linenumber: [@@base04, @background_color, false, false],
        color_margin_vc: [@@base04, @@base01, false, false],
        color_margin_change_history: [@@base04, @@base01, false, false],
        color_margin_folding: [@background_color, @background_color, false, false],
        color_marker_folding: [@background_color, @@base04, false, false],
        color_caret_line: [@foreground_color, @@base01, false, false],
        color_indent_guide: [@@base03, @background_color, false, false],
        color_marker_breakpoint: [@@base08, @@base08, false, false],
        color_marker_current: [@@base0D, @@base01, false, false],
        color_marker_vc_added: [@@base0B, @@base0B, false, false],
        color_marker_vc_modified: [@@base0A, @@base0A, false, false],
        color_marker_vc_deleted: [@@base08, @@base08, false, false],
        # frame
        color_mode_line: [@@base00, @@base04, false, false],
        color_mode_line_inactive: [@@base04, @@base03, false, false]
      }
    end
  end
end
