assert('select theme') do
  app = Mrbmacs::TestSupport::Application.new
  assert_equal('solarized-dark', app.theme.name)

  app.select_theme('solarized-light')
  assert_equal('solarized-light', app.theme.name)

  app.select_theme('not_exists')
  assert_equal('solarized-light', app.theme.name)
  assert_equal('not_exists not found', app.frame.echo_message)

  app.select_theme
  assert_equal('solarized-light', app.theme.name)
  assert_equal('test not found', app.frame.echo_message)

  $test_echo_gets[:output_text] = 'solarized-dark'
  app.select_theme
  assert_equal('solarized-dark', app.theme.name)
end

assert('create_theme_list') do
  list = Mrbmacs::Theme.create_theme_list
  assert_equal(4, list.size)
end
