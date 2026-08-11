module Mrbmacs
  module TestSupport
    class PreviewThemeView
      attr_reader :calls

      def initialize
        @calls = []
      end

      def sci_style_set_fore(style, value)
        @calls << [:foreground, style, value]
      end

      def sci_style_set_back(style, value)
        @calls << [:background, style, value]
      end

      def sci_style_set_italic(style, value)
        @calls << [:italic, style, value]
      end

      def sci_style_set_bold(style, value)
        @calls << [:bold, style, value]
      end
    end
  end
end

assert('PreviewthemeMode exposes semantic syntax roles and theme UI settings') do
  mode = Mrbmacs::PreviewthemeMode.new
  theme = Mrbmacs::Theme.new
  sections = mode.preview_sections(theme)

  assert_equal ['Semantic syntax roles', 'Theme UI settings'], sections.map { |section| section[0] }

  syntax = sections[0][1]
  assert_include syntax.map { |entry| entry[0] }, :comment
  assert_include syntax.map { |entry| entry[0] }, :number
  assert_equal theme.syntax_style(:comment).foreground,
               syntax.find { |entry| entry[0] == :comment }[1].foreground

  ui = sections[1][1]
  assert_include ui.map { |entry| entry[0] }, :color_linenumber
  assert_include ui.map { |entry| entry[0] }, :color_mode_line
  assert_false ui.map { |entry| entry[0] }.include?(:color_comment)
  assert_equal Mrbmacs::PREVIEW_THEME_LEXER_PROFILE, mode.lexer_profile
  assert_nil mode.lexer_profile.lexer
end

assert('PreviewthemeMode applies resolved preview colours through apply_theme') do
  mode = Mrbmacs::PreviewthemeMode.new
  theme = Mrbmacs::Theme.new
  view = Mrbmacs::TestSupport::PreviewThemeView.new
  default_style = theme.syntax_style(:default)

  mode.apply_theme(view, theme)

  assert_include view.calls, [:foreground, 0, default_style.foreground]
  assert_include view.calls, [:background, 0, default_style.background]
  assert_include view.calls, [:italic, 0, default_style.italic]
  assert_include view.calls, [:bold, 0, default_style.bold]
end

assert('preview_style_line formats a resolved StyleSpec') do
  app = Mrbmacs::TestSupport::Application.new
  style = Mrbmacs::StyleSpec.new(
    foreground: 0x123456,
    background: 0xabcdef,
    italic: true,
    bold: false
  )
  line = app.send(:preview_style_line, :comment, style)

  assert_include line, 'comment'
  assert_include line, '123456'
  assert_include line, 'ABCDEF'
  assert_include line, 'true'
  assert_include line, 'false'
end

assert('Preview Theme helper methods are not registered as commands') do
  commands = Mrbmacs::Command.instance_methods

  assert_include commands, :preview_theme
  assert_false commands.include?(:preview_style_line)
  assert_false commands.include?(:format_preview_color)
  assert_false commands.include?(:add_preview_text)
end
