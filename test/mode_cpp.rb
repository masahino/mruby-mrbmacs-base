assert('end_of_block?') do
  mode = Mrbmacs::CppMode.new
  assert_true(mode.end_of_block?('}'))
  assert_true(mode.end_of_block?(' }'))
  assert_true(mode.end_of_block?('} '))
  assert_false(mode.end_of_block?('hoge'))
end

assert('cpp lexer modes share only CLikeMode editing behaviour') do
  modes = [
    Mrbmacs::CppMode.new,
    Mrbmacs::GoMode.new,
    Mrbmacs::JavaMode.new,
    Mrbmacs::JavascriptMode.new
  ]

  modes.each do |mode|
    assert_true mode.is_a?(Mrbmacs::CLikeMode)
    assert_true mode.end_of_block?('  }')
  end

  assert_equal Mrbmacs::GO_LEXER_PROFILE, modes[1].lexer_profile
  assert_equal Mrbmacs::JAVA_LEXER_PROFILE, modes[2].lexer_profile
  assert_equal Mrbmacs::JAVASCRIPT_LEXER_PROFILE, modes[3].lexer_profile
end
