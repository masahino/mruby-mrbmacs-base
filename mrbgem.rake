MRuby::Gem::Specification.new('mruby-mrbmacs-base') do |spec|
  spec.license = 'MIT'
  spec.authors = 'masahino'
  spec.version = '0.2.0'
  spec.add_dependency 'mruby-scintilla-base', :github => 'masahino/mruby-scintilla-base'
  spec.add_dependency 'mruby-io', :core => 'mruby-io'
  spec.add_dependency 'mruby-dir'
  spec.add_dependency 'mruby-eval'
  spec.add_dependency 'mruby-onig-regexp'
  spec.add_dependency 'mruby-array-ext'
  spec.add_dependency 'mruby-symbol-ext'
  spec.add_dependency 'mruby-objectspace'
  spec.add_dependency 'mruby-optparse', :github => 'fastly/mruby-optparse'
  spec.add_dependency 'mruby-logger'
  spec.add_dependency 'mruby-iconv'
  spec.add_test_dependency 'mruby-require', :github => 'iij/mruby-require'
end
