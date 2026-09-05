assert('FrameBase#select_buffer filters candidates by prefix and reports the default in the prompt') do
  app = Mrbmacs::TestSupport::Application.new
  separator = app.frame.echo_win.sci_autoc_get_separator.chr
  captured_prompt = nil
  captured_list = nil
  captured_len = nil
  app.frame.define_singleton_method(:echo_gets) do |prompt, _text = '', &block|
    captured_prompt = prompt
    captured_list, captured_len = block.call('sc')
    'scratch'
  end

  result = app.frame.select_buffer('*scratch*', %w[scratch scratch2 other])

  assert_equal 'Switch to buffer: (default *scratch*) ', captured_prompt
  assert_equal "scratch#{separator}scratch2", captured_list
  assert_equal 2, captured_len
  assert_equal 'scratch', result
end
