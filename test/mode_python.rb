assert('PythonMode uses the Python lexer profile') do
  mode = Mrbmacs::PythonMode.new

  assert_equal Mrbmacs::PYTHON_LEXER_PROFILE, mode.lexer_profile
  assert_equal 'python', mode.lexer
  assert_equal Mrbmacs::PYTHON_KEYWORDS, mode.completion_keyword_list
  assert_equal Mrbmacs::PYTHON_KEYWORDS, mode.lexer_profile.keyword_sets[0]
  assert_equal '', mode.lexer_profile.keyword_sets[1]
  assert_equal '1', mode.lexer_profile.properties['fold']
end

assert('Python lexer profile maps every Lexilla display style') do
  styles = Mrbmacs::PYTHON_LEXER_PROFILE.styles

  assert_equal 21, styles.size
  assert_equal :comment, styles[Scintilla::SCE_P_COMMENTLINE]
  assert_equal :number, styles[Scintilla::SCE_P_NUMBER]
  assert_equal :string, styles[Scintilla::SCE_P_TRIPLEDOUBLE]
  assert_equal :operator, styles[Scintilla::SCE_P_OPERATOR]
  assert_equal :default, styles[Scintilla::SCE_P_IDENTIFIER]
  assert_equal :error, styles[Scintilla::SCE_P_STRINGEOL]
  assert_equal :builtin, styles[Scintilla::SCE_P_DECORATOR]
  assert_equal :property_use, styles[Scintilla::SCE_P_ATTRIBUTE]
end

assert('PythonMode completion uses profile keyword set 0') do
  mode = Mrbmacs::PythonMode.new

  assert_include mode.completion_keyword_list.split(' '), 'class'
  assert_include mode.completion_keyword_list.split(' '), 'yield'
end
