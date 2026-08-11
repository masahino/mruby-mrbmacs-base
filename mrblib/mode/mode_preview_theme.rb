module Mrbmacs
  # mode for preview-theme
  class PreviewthemeMode < Mode
    def initialize
      super
      @name = 'previewtheme'
      @lexer_profile = PREVIEW_THEME_LEXER_PROFILE
    end

    def apply_theme(view_win, theme, _overrides = nil)
      preview_entries(theme).each_with_index do |entry, style_number|
        apply_preview_style(view_win, style_number, entry[1])
      end
    end

    def preview_sections(theme)
      [
        ['Semantic syntax roles', syntax_entries(theme)],
        ['Theme UI settings', ui_entries(theme)]
      ]
    end

    def preview_entries(theme)
      preview_sections(theme).flat_map { |section| section[1] }
    end

    def syntax_entries(theme)
      syntax_roles.map { |role| [role, theme.syntax_style(role)] }.select { |entry| entry[1] }
    end

    def ui_entries(theme)
      theme.font_color.each_with_object([]) do |entry, result|
        name, value = entry
        next if syntax_theme_keys.include?(name)

        style = StyleSpec.from_legacy(value)
        result << [name, style] if style
      end
    end

    def end_of_block?(line)
      if line =~ /^\s*(end|else|fi|done|}).*$/
        true
      else
        false
      end
    end

    private

    def syntax_roles
      (StyleRole::LEGACY_NAMES.keys + StyleRole::PARENTS.keys).uniq
    end

    def syntax_theme_keys
      StyleRole::LEGACY_NAMES.values
    end

    def apply_preview_style(view_win, style_number, style)
      view_win.sci_style_set_fore(style_number, style.foreground) unless style.foreground.nil?
      view_win.sci_style_set_back(style_number, style.background) unless style.background.nil?
      view_win.sci_style_set_italic(style_number, style.italic) unless style.italic.nil?
      view_win.sci_style_set_bold(style_number, style.bold) unless style.bold.nil?
    end
  end
end
