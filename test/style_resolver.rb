module Mrbmacs
  module TestSupport
    class StyleView
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

assert('Theme resolves new roles through legacy colors') do
  theme = Mrbmacs::Base16DefaultDarkTheme.new
  assert_equal theme.font_color[:color_constant][0], theme.syntax_style(:number).foreground
  assert_equal theme.font_color[:color_default][0], theme.syntax_style(:operator).foreground
end

assert('StyleResolver applies override precedence by property') do
  theme = Mrbmacs::Base16DefaultDarkTheme.new
  overrides = Mrbmacs::StyleOverrides.new
  overrides.override(:comment, italic: false)
  overrides.override(:comment, lexer: :ruby, bold: true)
  overrides.override_scintilla(:ruby, 10, foreground: 123)
  resolver = Mrbmacs::StyleResolver.new(theme, overrides)
  style = resolver.resolve(:comment, lexer: :ruby, style_number: 10)

  assert_equal 123, style.foreground
  assert_equal theme.font_color[:color_comment][1], style.background
  assert_equal false, style.italic
  assert_equal true, style.bold
end

assert('StyleResolver applies a lexer profile') do
  theme = Mrbmacs::Base16DefaultDarkTheme.new
  profile = Mrbmacs::LexerProfile.new(:test, 'test', { 1 => :comment })
  view = Mrbmacs::TestSupport::StyleView.new
  Mrbmacs::StyleResolver.new(theme).apply(view, profile)

  assert_include view.calls, [:foreground, 1, theme.font_color[:color_comment][0]]
  assert_include view.calls, [:italic, 1, theme.font_color[:color_comment][2]]
end
