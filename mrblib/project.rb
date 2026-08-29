module Mrbmacs
  # Project
  class Project
    attr_reader :name, :root_directory
    attr_accessor :build_command, :last_build_command

    def initialize(root_directory)
      update(root_directory)
    end

    def guess_build_command
      build_types = {
        'Rakefile' => 'rake',
        'Makefile' => 'make',
        'makefile' => 'make',
        'build.sh' => './build.sh'
      }
      build_types.each do |k, v|
        return v if File.exist?("#{@root_directory}/#{k}")
      end
      nil
    end

    def update(root_directory)
      @root_directory = File.expand_path(root_directory)
      @name = File.basename(@root_directory)
      @build_command = guess_build_command
      @last_build_command = nil
    end
  end

  # Command
  module Command
    def open_project(root_directory = nil)
      if root_directory.nil?
        root_directory = read_dir_name('Project directory: ', @current_buffer.directory)
      end
      if root_directory != nil && Dir.exist?(root_directory)
        @project.update(root_directory)
        @frame.modeline(self)
      end
    end
  end
end
