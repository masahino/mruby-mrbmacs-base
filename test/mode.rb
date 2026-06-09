assert('Mode.add_keybind') do
  mode = Mrbmacs::Mode.new
  mode.add_keybind('x', 'hoge')
end

assert('Mode.instance returns same object') do
  assert_equal Mrbmacs::Mode.instance, Mrbmacs::Mode.instance
end

assert('Mode.instance preserves state') do
  mode = Mrbmacs::Mode.instance
  original_name = mode.name
  mode.name = 'singleton-test'
  assert_equal 'singleton-test', Mrbmacs::Mode.instance.name
  mode.name = original_name
end

assert('Mode.new is separate from Mode.instance') do
  assert_true(Mrbmacs::Mode.new != Mrbmacs::Mode.instance)
end
