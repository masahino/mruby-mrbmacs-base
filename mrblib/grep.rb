module Mrbmacs
  # Command
  module Command
    describe_command :grep, 'Run a grep command and display its matches.'

    def grep(command = nil)
      default_dir = @current_buffer.directory
      command = @frame.echo_gets("Run Grep[#{default_dir}]: ", 'grep -n ') if command.nil?
      return if command.nil?

      buffer_name = '*grep*'
      setup_result_buffer(buffer_name)
      result_buffer = Mrbmacs.get_buffer_from_name(@buffer_list, buffer_name)
      result_buffer.mode.pattern = GrepMode.extract_pattern(command)
      exec_shell_command(buffer_name, command, default_dir)
    end

  end
end
