assert('get_candidates 1') do
  mode = Mrbmacs::RubyMode.new
  assert_equal(['and'], mode.get_candidates_a('and'))
end

assert('RubyMode uses the Ruby lexer profile') do
  mode = Mrbmacs::RubyMode.new
  assert_equal Mrbmacs::RUBY_LEXER_PROFILE, mode.lexer_profile
  assert_equal 'ruby', mode.lexer
  assert_equal Mrbmacs::RUBY_KEYWORDS, mode.completion_keyword_list
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

assert('get_candidates String') do
  mode = Mrbmacs::RubyMode.new
  assert_equal(['"test".chomp', '"test".chomp!'], mode.get_candidates_a('"test".chom'))
end

assert('get_candidates Hash or Proc') do
  mode = Mrbmacs::RubyMode.new
  assert_equal(['{:a => 1, :b => 2}.each_key'], mode.get_candidates_a('{:a => 1, :b => 2}.each_k'))
end

assert('get_candidates Absolute Constant or class methods') do
  mode = Mrbmacs::RubyMode.new
  assert_equal(['::MRUBY_VERSION'], mode.get_candidates_a('::MRUBY_V'))
end

assert('get_candidates Constant or class methods') do
  mode = Mrbmacs::RubyMode.new
  assert_equal(['Mrbmacs::ModeManager::get_mode_by_filename',
                'Mrbmacs::ModeManager::get_mode_by_name',
                'Mrbmacs::ModeManager::get_mode_by_suffix'],
               mode.get_candidates_a('Mrbmacs::ModeManager::get_'))
end

assert('get_candidates Symbol') do
  mode = Mrbmacs::RubyMode.new
  assert_equal([':test.class', ':test.clone'], mode.get_candidates_a(':test.cl'))
end

assert('get_candidates Numeric') do
  mode = Mrbmacs::RubyMode.new
  assert_equal(true, mode.get_candidates_a('1.ab').include?('1.abs'))
end

assert('get_candidates Numeric(0xFFFF)') do
  mode = Mrbmacs::RubyMode.new
  assert_equal(['0xFFFF.next'], mode.get_candidates_a('0xFFFF.ne'))
end

assert('get_candidates global var') do
  mode = Mrbmacs::RubyMode.new
  assert_equal(['$stderr', '$stdin', '$stdout'], mode.get_candidates_a('$std'))
end

assert('get_candidates variable.func or func.func') do
  mode = Mrbmacs::RubyMode.new
  candidates = mode.get_candidates_a('$stderr.put')
  assert_true(candidates.include?('$stderr.puts'))
end

assert('get_candidates unknown') do
  mode = Mrbmacs::RubyMode.new
  #  candidates = Symbol.all_symbols.collect{|s| ":" + s.id2name}
  assert_equal(Array, mode.get_candidates_a('Mrbmacs::').class)
end

#      if line =~/^\s*(end|else|then|elsif|when|rescue|ensure|\}|\]|\)).*$/
assert('end_of_block?') do
  mode = Mrbmacs::RubyMode.new
  assert_equal true, mode.end_of_block?('end')
  assert_equal true, mode.end_of_block?('}')
  assert_equal true, mode.end_of_block?(']')
  assert_equal true, mode.end_of_block?(')')
end
