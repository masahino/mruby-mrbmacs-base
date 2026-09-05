def prepare_eval_last_exp(app, text, position = text.bytesize)
  view = app.frame.view_win
  additions = []
  newlines = []
  view.define_singleton_method(:sci_get_curline) { [text, position] }
  view.define_singleton_method(:sci_addtext) do |length, output|
    additions << [length, output]
  end
  view.define_singleton_method(:sci_newline) { newlines << true }
  [additions, newlines]
end

assert('eval_last_exp evaluates the expression before point') do
  app = Mrbmacs::TestSupport::Application.new
  additions, newlines = prepare_eval_last_exp(app, '160 / 4')

  app.eval_last_exp

  assert_equal [[2, '40']], additions
  assert_equal 2, newlines.length
end

assert('eval_last_exp displays a syntax error without raising it') do
  app = Mrbmacs::TestSupport::Application.new
  additions, newlines = prepare_eval_last_exp(app, '160 / 4=')

  app.eval_last_exp

  assert_true additions[0][1].include?('syntax error')
  assert_equal additions[0][1].bytesize, additions[0][0]
  assert_equal 2, newlines.length
end

assert('eval_last_exp displays a runtime error without raising it') do
  app = Mrbmacs::TestSupport::Application.new
  additions, = prepare_eval_last_exp(app, 'raise "failure"')

  app.eval_last_exp

  assert_true additions[0][1].include?('failure')
end

assert('eval_last_exp passes a byte length to Scintilla') do
  app = Mrbmacs::TestSupport::Application.new
  additions, = prepare_eval_last_exp(app, "'日本語'")

  app.eval_last_exp

  assert_equal '日本語', additions[0][1]
  assert_equal '日本語'.bytesize, additions[0][0]
end

assert('eval_buffer handles a syntax error without raising it') do
  app = Mrbmacs::TestSupport::Application.new
  view = app.frame.view_win
  view.define_singleton_method(:sci_get_length) { 8 }
  view.define_singleton_method(:sci_get_text) { |_length| '160 / 4=' }

  app.eval_buffer

  assert_true true
end
