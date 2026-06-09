assert('get_mode_by_suffix') do
  assert_equal('bash', Mrbmacs::ModeManager.get_mode_by_suffix('.sh'))
  assert_equal('cpp', Mrbmacs::ModeManager.get_mode_by_suffix('.c'))
  assert_equal('cpp', Mrbmacs::ModeManager.get_mode_by_suffix('.h'))
  assert_equal('cpp', Mrbmacs::ModeManager.get_mode_by_suffix('.cpp'))
  assert_equal('cpp', Mrbmacs::ModeManager.get_mode_by_suffix('.cxx'))
  assert_equal('css', Mrbmacs::ModeManager.get_mode_by_suffix('.css'))
  assert_equal('diff', Mrbmacs::ModeManager.get_mode_by_suffix('.diff'))
  assert_equal('fundamental', Mrbmacs::ModeManager.get_mode_by_suffix('.txt'))
  assert_equal('fundamental', Mrbmacs::ModeManager.get_mode_by_suffix(''))
  assert_equal('fundamental', Mrbmacs::ModeManager.get_mode_by_suffix('.hoge'))
  assert_equal('go', Mrbmacs::ModeManager.get_mode_by_suffix('.go'))
  assert_equal('haskell', Mrbmacs::ModeManager.get_mode_by_suffix('.hs'))
  assert_equal('html', Mrbmacs::ModeManager.get_mode_by_suffix('.html'))
  assert_equal('html', Mrbmacs::ModeManager.get_mode_by_suffix('.htm'))
  assert_equal('java', Mrbmacs::ModeManager.get_mode_by_suffix('.java'))
  assert_equal('javascript', Mrbmacs::ModeManager.get_mode_by_suffix('.js'))
  assert_equal('json', Mrbmacs::ModeManager.get_mode_by_suffix('.json'))
  assert_equal('markdown', Mrbmacs::ModeManager.get_mode_by_suffix('.md'))
  assert_equal('perl', Mrbmacs::ModeManager.get_mode_by_suffix('.pl'))
  assert_equal('python', Mrbmacs::ModeManager.get_mode_by_suffix('.py'))
  assert_equal('r', Mrbmacs::ModeManager.get_mode_by_suffix('.r'))
  assert_equal('ruby', Mrbmacs::ModeManager.get_mode_by_suffix('.rb'))
  assert_equal('rust', Mrbmacs::ModeManager.get_mode_by_suffix('.rs'))
  assert_equal('latex', Mrbmacs::ModeManager.get_mode_by_suffix('.tex'))
  assert_equal('yaml', Mrbmacs::ModeManager.get_mode_by_suffix('.yaml'))
  assert_equal('yaml', Mrbmacs::ModeManager.get_mode_by_suffix('.yml'))
  assert_equal('lisp', Mrbmacs::ModeManager.get_mode_by_suffix('.lisp'))
end

assert('get_mode_by_filename') do
  assert_equal('bash', Mrbmacs::ModeManager.get_mode_by_filename('test.sh'))
  assert_equal('cpp', Mrbmacs::ModeManager.get_mode_by_filename('/foo/bar/baz.c'))
  assert_equal('make', Mrbmacs::ModeManager.get_mode_by_filename('Makefile'))
  assert_equal('ruby', Mrbmacs::ModeManager.get_mode_by_filename('Rakefile'))
  assert_equal('latex', Mrbmacs::ModeManager.get_mode_by_filename('test.tex'))
  assert_equal('lisp', Mrbmacs::ModeManager.get_mode_by_filename('.lisp'))
end

assert('set_mode_by_filename') do
  assert_equal('ruby', Mrbmacs::ModeManager.set_mode_by_filename('hoge.rb').name)
  assert_equal('ruby', Mrbmacs::ModeManager.set_mode_by_filename('foo.bar.rb').name)
  assert_equal('css', Mrbmacs::ModeManager.set_mode_by_filename('hogehoge.css').name)
  assert_equal('diff', Mrbmacs::ModeManager.set_mode_by_filename('hogehoge.diff').name)
  assert_equal('make', Mrbmacs::ModeManager.set_mode_by_filename('Makefile').name)
  assert_equal('latex', Mrbmacs::ModeManager.set_mode_by_filename('test.tex').name)
  assert_equal('lisp', Mrbmacs::ModeManager.set_mode_by_filename('test.lisp').name)
  assert_equal('ruby', Mrbmacs::ModeManager.set_mode_by_filename('.hogehoge.rb').name)
end

assert('set_mode_by_filename returns shared instance') do
  assert_equal Mrbmacs::RubyMode.instance, Mrbmacs::ModeManager.set_mode_by_filename('hoge.rb')
end

assert('mode Class') do
  assert_equal Mrbmacs::RubyMode, Mrbmacs::ModeManager.set_mode_by_filename('a.rb').class
end

assert('get_mode_by_name') do
  assert_equal Mrbmacs::RubyMode.instance, Mrbmacs::ModeManager.get_mode_by_name('ruby')
  assert_equal nil, Mrbmacs::ModeManager.get_mode_by_name('default')
end

assert('mode subclass instance returns same object') do
  assert_equal Mrbmacs::RubyMode.instance, Mrbmacs::RubyMode.instance
end

assert('add_mode') do
  assert_equal 'fundamental', Mrbmacs::ModeManager.get_mode_by_suffix('xyz')
  Mrbmacs::ModeManager.add_mode('.xyz', 'hogehoge')
  assert_equal 'fundamental', Mrbmacs::ModeManager.get_mode_by_suffix('xyz')
end
