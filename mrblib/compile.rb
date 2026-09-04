module Mrbmacs
  # Command
  module Command
    describe_command :compile, 'Run a compile command for the current project.'

    def compile
      default_command = @project.build_command
      default_command = @project.last_build_command if @project.last_build_command != nil
      default_command = @current_buffer.mode.build_command if default_command.nil?

      command = @frame.echo_gets("Compile command[#{@project.root_directory}]: ", default_command)
      return if command.nil?

      @project.last_build_command = command
      exec_shell_command(
        '*compilation*',
        @project.last_build_command,
        @project.root_directory
      )
    end

    describe_command :recompile, 'Repeat the most recent compile command.'

    def recompile
      if @project.last_build_command.nil?
        compile
      else
        exec_shell_command(
          '*compilation*',
          @project.last_build_command,
          @project.root_directory
        )
      end
    end

  end
end
