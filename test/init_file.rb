module Mrbmacs
  module InitFileTestSupport
    class Logger
      def debug(_message)
      end
    end

    class Application < Mrbmacs::Application
      attr_reader :loaded_files

      def initialize
        @logger = Logger.new
        @loaded_files = []
      end

      def load_file(filename)
        @loaded_files << filename
      end
    end

    def self.create_directory(path)
      parent = File.dirname(path)
      create_directory(parent) unless Dir.exist?(parent)
      Dir.mkdir(path) unless Dir.exist?(path)
    end

    def self.create_file(filename)
      create_directory(File.dirname(filename))
      File.open(filename, 'w') { |file| file.write("# test init file\n") }
    end

    def self.remove_tree(path)
      return unless File.exist?(path)

      if File.directory?(path)
        Dir.entries(path).each do |entry|
          next if entry == '.' || entry == '..'

          remove_tree(File.join(path, entry))
        end
        Dir.rmdir(path)
      else
        File.delete(path)
      end
    end

    def self.with_environment(label)
      old_home = ENV['HOME']
      old_xdg = ENV['XDG_CONFIG_HOME']
      root = File.join(ENV['TMPDIR'] || '/tmp', "mrbmacs-init-#{$$}-#{label}")
      remove_tree(root)
      create_directory(root)
      ENV['HOME'] = File.join(root, 'home')
      create_directory(ENV['HOME'])
      yield(root)
    ensure
      if old_home.nil?
        ENV.delete('HOME')
      else
        ENV['HOME'] = old_home
      end
      if old_xdg.nil?
        ENV.delete('XDG_CONFIG_HOME')
      else
        ENV['XDG_CONFIG_HOME'] = old_xdg
      end
      remove_tree(root) unless root.nil?
    end
  end
end

assert('load_init_file prefers XDG_CONFIG_HOME and loads only one file') do
  Mrbmacs::InitFileTestSupport.with_environment('xdg') do |root|
    xdg_home = File.join(root, 'xdg')
    ENV['XDG_CONFIG_HOME'] = xdg_home
    xdg_file = File.join(xdg_home, 'mrbmacs', 'init.rb')
    Mrbmacs::InitFileTestSupport.create_file(xdg_file)
    Mrbmacs::InitFileTestSupport.create_file(
      File.join(ENV['HOME'], '.config', 'mrbmacs', 'init.rb')
    )
    Mrbmacs::InitFileTestSupport.create_file(File.join(ENV['HOME'], '.mrbmacsrc'))

    app = Mrbmacs::InitFileTestSupport::Application.new
    app.load_init_file
    assert_equal [xdg_file], app.loaded_files
  end
end

assert('load_init_file uses the default XDG path when XDG_CONFIG_HOME is unset') do
  Mrbmacs::InitFileTestSupport.with_environment('default-xdg') do
    ENV.delete('XDG_CONFIG_HOME')
    init_file = File.join(ENV['HOME'], '.config', 'mrbmacs', 'init.rb')
    Mrbmacs::InitFileTestSupport.create_file(init_file)

    app = Mrbmacs::InitFileTestSupport::Application.new
    app.load_init_file
    assert_equal [init_file], app.loaded_files
  end
end

assert('load_init_file falls back from XDG_CONFIG_HOME to the default XDG path') do
  Mrbmacs::InitFileTestSupport.with_environment('xdg-fallback') do |root|
    ENV['XDG_CONFIG_HOME'] = File.join(root, 'empty-xdg')
    init_file = File.join(ENV['HOME'], '.config', 'mrbmacs', 'init.rb')
    Mrbmacs::InitFileTestSupport.create_file(init_file)

    app = Mrbmacs::InitFileTestSupport::Application.new
    app.load_init_file
    assert_equal [init_file], app.loaded_files
  end
end

assert('load_init_file treats an empty XDG_CONFIG_HOME as unset') do
  Mrbmacs::InitFileTestSupport.with_environment('empty-xdg') do
    ENV['XDG_CONFIG_HOME'] = ''
    init_file = File.join(ENV['HOME'], '.config', 'mrbmacs', 'init.rb')
    Mrbmacs::InitFileTestSupport.create_file(init_file)

    app = Mrbmacs::InitFileTestSupport::Application.new
    app.load_init_file
    assert_equal [init_file], app.loaded_files
  end
end

assert('load_init_file ignores a relative XDG_CONFIG_HOME') do
  Mrbmacs::InitFileTestSupport.with_environment('relative-xdg') do
    ENV['XDG_CONFIG_HOME'] = 'relative-config'
    init_file = File.join(ENV['HOME'], '.config', 'mrbmacs', 'init.rb')
    Mrbmacs::InitFileTestSupport.create_file(init_file)

    app = Mrbmacs::InitFileTestSupport::Application.new
    app.load_init_file
    assert_equal [init_file], app.loaded_files
  end
end

assert('load_init_file falls back to .mrbmacs') do
  Mrbmacs::InitFileTestSupport.with_environment('mrbmacs') do
    ENV.delete('XDG_CONFIG_HOME')
    init_file = File.join(ENV['HOME'], '.mrbmacs')
    Mrbmacs::InitFileTestSupport.create_file(init_file)

    app = Mrbmacs::InitFileTestSupport::Application.new
    app.load_init_file
    assert_equal [init_file], app.loaded_files
  end
end

assert('load_init_file skips a .mrbmacs directory and falls back to .mrbmacsrc') do
  Mrbmacs::InitFileTestSupport.with_environment('mrbmacs-directory') do
    ENV.delete('XDG_CONFIG_HOME')
    Mrbmacs::InitFileTestSupport.create_directory(File.join(ENV['HOME'], '.mrbmacs'))
    init_file = File.join(ENV['HOME'], '.mrbmacsrc')
    Mrbmacs::InitFileTestSupport.create_file(init_file)

    app = Mrbmacs::InitFileTestSupport::Application.new
    app.load_init_file
    assert_equal [init_file], app.loaded_files
  end
end

assert('load_init_file falls back to .mrbmacsrc') do
  Mrbmacs::InitFileTestSupport.with_environment('mrbmacsrc') do
    ENV.delete('XDG_CONFIG_HOME')
    init_file = File.join(ENV['HOME'], '.mrbmacsrc')
    Mrbmacs::InitFileTestSupport.create_file(init_file)

    app = Mrbmacs::InitFileTestSupport::Application.new
    app.load_init_file
    assert_equal [init_file], app.loaded_files
  end
end

assert('load_init_file does nothing when no init file exists') do
  Mrbmacs::InitFileTestSupport.with_environment('missing') do
    ENV.delete('XDG_CONFIG_HOME')
    app = Mrbmacs::InitFileTestSupport::Application.new
    app.load_init_file
    assert_equal [], app.loaded_files
  end
end
