module Mrbmacs
  # Version control information for a working directory.
  class VC
    attr_reader :type, :root_directory, :branch, :state

    def self.parse_diff_hunks(output)
      hunks = []
      output.each_line do |line|
        match = line.match(/^@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@/)
        next if match.nil?

        old_count = match[2].nil? ? 1 : match[2].to_i
        new_count = match[4].nil? ? 1 : match[4].to_i
        type = if old_count == 0
                 :added
               elsif new_count == 0
                 :deleted
               else
                 :modified
               end
        hunks << {
          type: type,
          old_start: match[1].to_i,
          old_count: old_count,
          new_start: match[3].to_i,
          new_count: new_count
        }
      end
      hunks
    end

    def self.marker_lines(changes)
      markers = []
      changes.each do |change|
        if change[:type] == :deleted
          markers << [change[:type], [change[:new_start] - 1, 0].max]
          next
        end

        first_line = [change[:new_start] - 1, 0].max
        change[:new_count].times do |offset|
          markers << [change[:type], first_line + offset]
        end
      end
      markers
    end

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

      relative_path, error = repository_relative_path(filename)
      return [error, 1] unless error.nil?

      execute(['diff', '--no-ext-diff', 'HEAD', '--', relative_path], @root_directory)
    end

    def changes(filename)
      return [[], 1] unless managed?

      relative_path, error = repository_relative_path(filename)
      return [[], 1] unless error.nil?

      output, status = execute(
        ['diff', '--no-ext-diff', '--unified=0', 'HEAD', '--', relative_path],
        @root_directory
      )
      return [[], status] unless status == 0

      [self.class.parse_diff_hunks(output), 0]
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

    def repository_relative_path(filename)
      path = File.expand_path(filename)
      root = @root_directory
      prefix = root.end_with?(File::SEPARATOR) ? root : "#{root}#{File::SEPARATOR}"
      return [nil, "#{path} is outside the repository"] unless path.start_with?(prefix)

      [path[prefix.length..-1], nil]
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

  class Application
    private

    def vc_refresh_gutter
      view_win = @frame.view_win
      [
        MARKERN_VC_ADDED,
        MARKERN_VC_MODIFIED,
        MARKERN_VC_DELETED
      ].each { |marker| view_win.sci_marker_delete_all(marker) }

      return if @current_buffer.filename == ''

      vcinfo = @current_buffer.vcinfo || VC.new(@current_buffer.directory)
      return unless vcinfo.managed?

      changes, status = vcinfo.changes(@current_buffer.filename)
      return unless status == 0

      marker_numbers = {
        added: MARKERN_VC_ADDED,
        modified: MARKERN_VC_MODIFIED,
        deleted: MARKERN_VC_DELETED
      }
      VC.marker_lines(changes).each do |type, line|
        view_win.sci_marker_add(line, marker_numbers[type])
      end
    end

  end

  module Command
    describe_command :vc_diff, 'Display the current file changes from Git.'

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
