assert('modeline_str') do
  app = Mrbmacs::TestSupport::Application.new
  assert_equal '(', app.modeline_str[0]
end

assert('modeline_format') do
  app = Mrbmacs::TestSupport::Application.new
  app.modeline_format 'hoge'
  assert_equal 'hoge', app.modeline.format
  app.modeline_format '#{modeline_eol}'
  assert_equal '#{modeline_eol}', app.modeline.format
end

assert('modeline_enoding') do
  app = Mrbmacs::TestSupport::Application.new
  assert_equal 'utf-8', app.modeline_encoding
end

assert('modeline_eol') do
  app = Mrbmacs::TestSupport::Application.new
  assert_equal 'CRLF', app.modeline_eol
end

assert('modelne_buffername') do
  app = Mrbmacs::TestSupport::Application.new
  assert_equal '*scratch*', app.modeline_buffername
end

assert('modeline_pos') do
  app = Mrbmacs::TestSupport::Application.new
  assert_equal '(1,1)', app.modeline_pos
end

assert('modeline_modename') do
  app = Mrbmacs::TestSupport::Application.new
  assert_equal 'irb', app.modeline_modename
end

assert('modeline_additional_info') do
  app = Mrbmacs::TestSupport::Application.new
  assert_equal '', app.modeline_additional_info
end

assert('modeline_vcinfo') do
  app = Mrbmacs::TestSupport::Application.new
  assert_equal true, app.modeline_vcinfo.is_a?(String)
end
