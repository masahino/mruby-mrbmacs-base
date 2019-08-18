assert('is_end_of_block') do
  mode = Mrbmacs::CppMode.new
  assert_true(mode.is_end_of_block('}'))
  assert_true(mode.is_end_of_block(' }'))
  assert_true(mode.is_end_of_block('} '))
  assert_false(mode.is_end_of_block('hoge'))
end
