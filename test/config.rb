assert('Config.new') do
  config = Mrbmacs::Config.new
  assert_equal false, config.use_builtin_indent
  assert_equal Mrbmacs::Base16DefaultDarkTheme, config.theme
  assert_equal Hash, config.ext.class
end
