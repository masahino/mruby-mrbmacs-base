module Mrbmacs
  # Version control information for a working directory.
  class VC
    attr_reader :type, :root_directory, :branch, :state

    def initialize(directory, runner = nil)
      @directory = File.expand_path(directory)
      @runner = runner || method(:run_git)
      @type = nil
      @root_directory = nil
      @branch = ''
      @state = :unmanaged
      discover
    end

    def managed?
      @state == :managed
    end

    def detached?
      managed? && @branch.start_with?('@')
    end

    def to_s
      managed? ? "Git:#{@branch}" : ''
    end

    private

    def discover
      root, status = execute('rev-parse --show-toplevel')
      unless status == 0
        @state = status == 127 ? :unavailable : :unmanaged
        return
      end

      @type = :git
      @root_directory = root.chomp
      @state = :managed
      branch, branch_status = execute('symbolic-ref --quiet --short HEAD')
      if branch_status == 0
        @branch = branch.chomp
      else
        revision, revision_status = execute('rev-parse --short HEAD')
        @branch = revision_status == 0 ? "@#{revision.chomp}" : '@unknown'
      end
    end

    def execute(command)
      @runner.call(@directory, command)
    end

    # Commands passed here are fixed internally; changing directory avoids
    # interpolating a user-controlled path into the shell command.
    def run_git(directory, command)
      output = ''
      status = nil
      Dir.chdir(directory) do
        output = `git #{command} 2>&1`
        status = $?
      end
      [output, status.nil? ? 1 : status.exitstatus]
    rescue StandardError => e
      [e.to_s, 1]
    end
  end
end
