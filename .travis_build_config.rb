class MRuby::Build
  # mruby 3.3+ splits core objects into libmruby_core.a, but gem binaries
  # in this project still expect both archives to be linked.
  def libraries
    [libmruby_static, libmruby_core_static]
  end
end

MRuby::Build.new do |conf|
  toolchain :gcc
  conf.gembox 'default'

  conf.gem :github => 'masahino/mruby-scintilla-base' do |g|
    g.download_scintilla
  end
  conf.gem github: 'iij/mruby-regexp-pcre', canonical: true do |g|
    g.skip_test = true
  end
  conf.gem :github => 'mattn/mruby-iconv' do |g|
    g.skip_test = true
    if RUBY_PLATFORM.include?('linux')
      g.linker.libraries.delete 'iconv'
    end
  end
  conf.gem File.expand_path(File.dirname(__FILE__))

  conf.enable_test
  conf.enable_bintest
  conf.linker do |linker|
    linker.libraries << "stdc++"
  end
end
