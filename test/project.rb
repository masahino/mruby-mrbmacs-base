module Mrbmacs
  module TestSupport
    class ProjectApplication < Application
      attr_reader :shell_commands

      def initialize(argv = [])
        @shell_commands = []
        super(argv)
      end

      def exec_shell_command(buffer_name, command, directory = nil)
        @shell_commands << [buffer_name, command, directory]
      end
    end
  end
end

assert('Project keeps an absolute root and its basename as its name') do
  project = Mrbmacs::Project.new('/tmp/example-project')

  assert_equal '/tmp/example-project', project.root_directory
  assert_equal 'example-project', project.name
end

assert('Project update refreshes name and build state without changing cwd') do
  project = Mrbmacs::Project.new('/tmp/example-project')
  project.build_command = 'old build'
  project.last_build_command = 'old command'
  original_directory = Dir.getwd

  project.update('/tmp/next-project')

  assert_equal '/tmp/next-project', project.root_directory
  assert_equal 'next-project', project.name
  assert_nil project.build_command
  assert_nil project.last_build_command
  assert_equal original_directory, Dir.getwd
end

assert('Application exposes its current project') do
  app = Mrbmacs::TestSupport::Application.new

  assert_true app.project.is_a?(Mrbmacs::Project)
end

assert('compile and recompile execute in the project root') do
  app = Mrbmacs::TestSupport::ProjectApplication.new
  app.project.update('/tmp/example-project')
  app.project.build_command = 'build command'
  old_output_text = $test_echo_gets[:output_text]
  $test_echo_gets[:output_text] = 'selected command'

  app.compile
  app.recompile

  assert_equal [
    ['*compilation*', 'selected command', '/tmp/example-project'],
    ['*compilation*', 'selected command', '/tmp/example-project']
  ], app.shell_commands
ensure
  $test_echo_gets[:output_text] = old_output_text
end

assert('grep executes in the current buffer directory') do
  app = Mrbmacs::TestSupport::ProjectApplication.new
  directory = app.current_buffer.directory

  app.grep('grep -n pattern')

  assert_equal [
    ['*grep*', 'grep -n pattern', directory]
  ], app.shell_commands
end
