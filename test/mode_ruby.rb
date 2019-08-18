assert('get_candidates 1') do
  mode = Mrbmacs::RubyMode.new
  assert_equal(['and'], mode.get_candidates_a("and"))
end

assert('get_candidates String') do
  mode = Mrbmacs::RubyMode.new
  assert_equal(['"test".chomp', '"test".chomp!'], mode.get_candidates_a('"test".chom'))
end

assert('get_candidates Regexp') do
  mode = Mrbmacs::RubyMode.new
  assert_equal(['/hoge/.skip'], mode.get_candidates_a('/hoge/.sk'))
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
  assert_equal(['Mrbmacs::Mode::get_mode_by_suffix'], mode.get_candidates_a('Mrbmacs::Mode::get_'))
end

assert('get_candidates Symbol') do
  mode = Mrbmacs::RubyMode.new
  assert_equal([':test.class', ':test.clone'], mode.get_candidates_a(':test.cl'))
end

assert('get_candidates Numeric') do
  mode = Mrbmacs::RubyMode.new
  candidates = 1.methods.collect{|m| m.to_s}.sort
  assert_equal(['1.abs'], mode.get_candidates_a('1.ab'))
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
  assert_equal(["$stderr.puts"], mode.get_candidates_a("$stderr.put"))
end

assert('get_candidates unknown') do
  mode = Mrbmacs::RubyMode.new
#  candidates = Symbol.all_symbols.collect{|s| ":" + s.id2name}
  assert_equal(Array, mode.get_candidates_a('Mrbmacs::').class)
end
