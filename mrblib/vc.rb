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

    def stage(filename)
      return ['', 1] unless managed?

      relative_path, error = repository_relative_path(filename)
      return [error, 1] unless error.nil?

      execute(['add', '--', relative_path], @root_directory)
    end

    def unstage(filename)
      return ['', 1] unless managed?

      relative_path, error = repository_relative_path(filename)
      return [error, 1] unless error.nil?

      execute(['restore', '--staged', '--', relative_path], @root_directory)
    end

    def commit(message)
      return ['', 1] unless managed?

      execute(['commit', '-m', message], @root_directory)
    end

    def status
      return ['', 1] unless managed?

      output, status = execute(['status', '--porcelain=v1', '-z'], @root_directory)
      return [[], status] unless status == 0

      entries = []
      fields = output.split("\0")
      index = 0
      while index < fields.length
        field = fields[index]
        break if field == ''

        index_status = field[0, 1]
        worktree_status = field[1, 1]
        path = field[3..-1]
        original_path = nil
        if index_status == 'R' || index_status == 'C' ||
           worktree_status == 'R' || worktree_status == 'C'
          index += 1
          original_path = fields[index]
        end
        entries << {
          index: index_status,
          worktree: worktree_status,
          path: path,
          original_path: original_path
        }
        index += 1
      end
      [entries, 0]
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
      command = "#{(['git'] + arguments).map { |argument| shell_quote(argument) }.join(' ')} 2>&1"
      Dir.chdir(directory) do
        output = IO.popen(command, 'r') { |io| io.read }
        status = $?
        exitstatus = status.respond_to?(:exitstatus) ? status.exitstatus : status
        [output, exitstatus]
      end
    rescue StandardError => e
      [e.to_s, 1]
    end

    def shell_quote(argument)
      "'#{argument.to_s.gsub("'") { %q('"'"') }}'"
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

    def vc_move_change(direction)
      win = @frame.view_win
      current_line = win.sci_line_from_position(win.sci_get_current_pos)

      return if @current_buffer.filename == ''

      vcinfo = @current_buffer.vcinfo || VC.new(@current_buffer.directory)
      unless vcinfo.managed?
        message 'File is not in a Git repository'
        return
      end

      changes, status = vcinfo.changes(@current_buffer.filename)
      unless status == 0
        message 'Git diff failed'
        return
      end

      if changes.empty?
        message 'No VC changes'
        return
      end

      lines = changes.map { |change| [change[:new_start] - 1, 0].max }

      line = if direction == :next
               lines.find { |l| l > current_line } || lines.first
             else
               lines.reverse.find { |l| l < current_line } || lines.last
             end

      win.sci_goto_line(line)
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

    describe_command :vc_next_change, 'Go to next change'
    def vc_next_change
      vc_move_change(:next)
    end

    describe_command :vc_previous_change, 'Go to previous change'
    def vc_previous_change
      vc_move_change(:previous)
    end

    describe_command :vc_stage_file, 'Stage the current file in Git.'
    def vc_stage_file
      if @current_buffer.filename == ''
        message 'Buffer is not visiting a file'
        return false
      end

      if @frame.view_win.sci_get_modify != 0
        message 'Buffer has unsaved changes'
        return false
      end

      vcinfo = @current_buffer.vcinfo || VC.new(@current_buffer.directory)
      unless vcinfo.managed?
        message 'File is not in a Git repository'
        return false
      end

      output, status = vcinfo.stage(@current_buffer.filename)
      unless status == 0
        message(output.chomp == '' ? 'Git add failed' : output.chomp)
        return false
      end

      vc_refresh_gutter
      message 'File staged'
      true
    end

    describe_command :vc_unstage_file, 'Unstage the current file in Git.'
    def vc_unstage_file
      if @current_buffer.filename == ''
        message 'Buffer is not visiting a file'
        return false
      end

      vcinfo = @current_buffer.vcinfo || VC.new(@current_buffer.directory)
      unless vcinfo.managed?
        message 'File is not in a Git repository'
        return false
      end

      output, status = vcinfo.unstage(@current_buffer.filename)
      unless status == 0
        message(output.chomp == '' ? 'Git unstage failed' : output.chomp)
        return false
      end

      vc_refresh_gutter
      message 'File unstaged'
      true
    end

    describe_command :vc_commit, 'Commit staged changes in Git.'
    def vc_commit
      source_buffer = @current_buffer
      directory = if source_buffer.mode.is_a?(VCStatusMode)
                    source_buffer.mode.root_directory
                  else
                    source_buffer.directory
                  end
      vcinfo = source_buffer.vcinfo || VC.new(directory)
      unless vcinfo.managed?
        message 'File is not in a Git repository'
        return false
      end

      entries, status = vcinfo.status
      unless status == 0
        message 'Git status failed'
        return false
      end
      unless entries.any? { |entry| entry[:index] != ' ' && entry[:index] != '?' }
        message 'No staged changes'
        return false
      end

      commit_message = @vc_commit_message || ''
      commit_message = @frame.echo_gets('Commit message: ', commit_message)
      return false if commit_message.nil?

      commit_message = commit_message.chomp
      unless commit_message =~ /\S/
        message 'Commit message is empty'
        return false
      end

      output, status = vcinfo.commit(commit_message)
      unless status == 0
        @vc_commit_message = commit_message
        message(output.chomp == '' ? 'Git commit failed' : output.chomp)
        return false
      end

      @vc_commit_message = nil
      if source_buffer.mode.is_a?(VCStatusMode)
        vc_status
      else
        vc_refresh_gutter
      end
      message 'Committed staged changes'
      true
    end

    describe_command :vc_status, 'Display the Git working tree status.'
    def vc_status
      source_buffer = @current_buffer
      vcinfo = source_buffer.vcinfo || VC.new(source_buffer.directory)
      unless vcinfo.managed?
        message 'File is not in a Git repository'
        return false
      end

      entries, status = vcinfo.status
      unless status == 0
        message 'Git status failed'
        return false
      end

      header = "+-- Staged (index)\n" \
               "|+-- Unstaged (working tree)\n"
      paths = [nil, nil]
      if entries.empty?
        output = "#{header}Working tree clean\n"
        paths << nil
      else
        lines = entries.map do |entry|
          path = vc_status_display_path(entry[:path])
          unless entry[:original_path].nil?
            path = "#{vc_status_display_path(entry[:original_path])} -> #{path}"
          end
          paths << entry[:path]
          "#{entry[:index]}#{entry[:worktree]} #{path}"
        end
        output = "#{header}#{lines.join("\n")}\n"
      end

      setup_result_buffer('*VC Status*')
      @frame.view_win.sci_set_read_only(0)
      @frame.view_win.sci_set_text(output)
      @current_buffer.vcinfo = vcinfo
      @current_buffer.mode = VCStatusMode.instance
      @current_buffer.mode.root_directory = vcinfo.root_directory
      @current_buffer.mode.paths = paths
      update_buffer_mode(@current_buffer)
      @frame.view_win.sci_set_save_point
      @frame.view_win.sci_set_read_only(1)
      true
    end

    private

    def vc_status_display_path(path)
      escaped = path.gsub('\\') { '\\\\' }
      escaped = escaped.gsub("\n") { '\\n' }
      escaped = escaped.gsub("\r") { '\\r' }
      escaped.gsub("\t") { '\\t' }
    end
  end
end
