module Mrbmacs
  # Command
  module Command
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
