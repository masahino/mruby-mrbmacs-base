assert('RubyMode uses the Ruby lexer profile') do
  mode = Mrbmacs::RubyMode.new
  assert_equal Mrbmacs::RUBY_LEXER_PROFILE, mode.lexer_profile
  assert_equal 'ruby', mode.lexer
  assert_equal Mrbmacs::RUBY_KEYWORDS, mode.lexer_profile.keyword_sets[0]
  assert_equal '1', mode.lexer_profile.properties['fold']
  assert_equal :comment, mode.lexer_profile.styles[Scintilla::SCE_RB_COMMENTLINE]
  assert_equal :number, mode.lexer_profile.styles[Scintilla::SCE_RB_NUMBER]
  assert_equal :operator, mode.lexer_profile.styles[Scintilla::SCE_RB_OPERATOR]
  assert_equal :string, mode.lexer_profile.styles[Scintilla::SCE_RB_STRING_Q]
  assert_equal :regexp, mode.lexer_profile.styles[Scintilla::SCE_RB_STRING_QR]
end

assert('Ruby lexer profile improves previously unstyled Ruby syntax') do
  mode = Mrbmacs::RubyMode.new
  theme = Mrbmacs::Base16DefaultDarkTheme.new

  quoted = theme.syntax_style(mode.lexer_profile.styles[Scintilla::SCE_RB_STRING_Q])
  assert_equal theme.font_color[:color_string][0], quoted.foreground
  assert_not_equal theme.font_color[:color_default][0], quoted.foreground

  operator = theme.syntax_style(mode.lexer_profile.styles[Scintilla::SCE_RB_OPERATOR])
  assert_equal theme.font_color[:color_default][0], operator.foreground
  assert_not_equal theme.font_color[:color_builtin][0], operator.foreground
end

#      if line =~/^\s*(end|else|then|elsif|when|rescue|ensure|\}|\]|\)).*$/
assert('end_of_block?') do
  mode = Mrbmacs::RubyMode.new
  assert_equal true, mode.end_of_block?('end')
  assert_equal true, mode.end_of_block?('}')
  assert_equal true, mode.end_of_block?(']')
  assert_equal true, mode.end_of_block?(')')
end
