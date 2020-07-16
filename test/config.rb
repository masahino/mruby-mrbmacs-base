require File.dirname(__FILE__) + '/test_helper.rb'

assert('Congig.new') do
  app = Mrbmacs::TestApp.new
  config = Mrbmacs::Config.new
  assert_equal false, config.use_builtin_completion
  assert_equal false, config.use_builtin_indent
  assert_equal Mrbmacs::SolarizedDarkTheme, config.theme
  assert_equal Hash, config.ext.class
end