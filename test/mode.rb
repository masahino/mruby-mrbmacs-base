assert('Mode.add_keybind') do
  mode = Mrbmacs::Mode.new
  mode.add_keybind('x', 'hoge')
  assert_equal 'hoge', mode.keymap['x']
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

assert('Mode delegates lexer configuration to its profile') do
  mode = Mrbmacs::Mode.new
  view = Object.new
  selected = nil
  view.define_singleton_method(:sci_set_lexer_language) { |lexer| selected = lexer }

  mode.apply_lexer(view)
  assert_equal Mrbmacs::FUNDAMENTAL_LEXER_PROFILE.lexer, selected
end
