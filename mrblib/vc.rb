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

    def diff(filename)
      return ['', 1] unless managed?

      path = File.expand_path(filename)
      root = @root_directory
      prefix = root.end_with?(File::SEPARATOR) ? root : "#{root}#{File::SEPARATOR}"
      return ["#{path} is outside the repository", 1] unless path.start_with?(prefix)

      relative_path = path[prefix.length..-1]
      execute(['diff', '--no-ext-diff', 'HEAD', '--', relative_path], root)
    end

    private

    def discover
      root, status = execute(['rev-parse', '--show-toplevel'])
      unless status == 0
        @state = status == 127 ? :unavailable : :unmanaged
        return
      end

      @type = :git
      @root_directory = root.chomp
      @state = :managed
      branch, branch_status = execute(['symbolic-ref', '--quiet', '--short', 'HEAD'])
      if branch_status == 0
        @branch = branch.chomp
      else
        revision, revision_status = execute(['rev-parse', '--short', 'HEAD'])
        @branch = revision_status == 0 ? "@#{revision.chomp}" : '@unknown'
      end
    end

    def execute(arguments, directory = @directory)
      @runner.call(directory, arguments)
    end

    def run_git(directory, arguments)
      reader, writer = IO.pipe
      pid = nil
      Dir.chdir(directory) do
        pid = Process.spawn('git', *arguments, out: writer.fileno, err: writer.fileno)
      end
      writer.close
      output = reader.read
      reader.close
      Process.waitpid(pid)
      [output, $?.exitstatus]
    rescue StandardError => e
      writer.close unless writer.nil? || writer.closed?
      reader.close unless reader.nil? || reader.closed?
      [e.to_s, 1]
    end
  end

  module Command
    def vc_diff
      source_buffer = @current_buffer
      if source_buffer.filename == ''
        message 'Buffer is not visiting a file'
        return
      end

      vcinfo = source_buffer.vcinfo || VC.new(source_buffer.directory)
      unless vcinfo.managed?
        message 'File is not in a Git repository'
        return
      end

      output, status = vcinfo.diff(source_buffer.filename)
      if status != 0
        message(output.chomp == '' ? 'Git diff failed' : output.chomp)
        return
      end
      if output == ''
        message 'No differences'
        return
      end

      buffer_name = '*vc-diff*'
      setup_result_buffer(buffer_name)
      @frame.view_win.sci_set_read_only(0)
      @frame.view_win.sci_set_text(output)
      @current_buffer.mode = DiffMode.instance
      update_buffer_mode(@current_buffer)
      @frame.view_win.sci_set_save_point
      @frame.view_win.sci_set_read_only(1)
    end
  end
end
