module Mrbmacs
  # command
  module Command
    def execute_extended_command
      input_str = @frame.echo_gets('M-x ') do |input_text|
        command_candidate = @command_list.select { |item| item.start_with?(input_text) }
        [command_candidate.join(@frame.echo_win.sci_autoc_get_separator.chr), input_text.length]
      end
      return if input_str.nil?

      args = input_str.split(/\s+/)
      command = args.shift
      args = args.join(' ')
      args = nil if args == ''
      begin
        instance_eval("#{command.gsub('-', '_')}(#{args})", __FILE__, __LINE__)
      rescue StandardError => e
        @logger.error e.to_s
        message "#{command} error"
      end
    end
  end

  # Application
  class Application
    include Command

    def method_missing(method, *args)
      if method.to_s[0..3].upcase == 'SCI_'
        @logger.debug "call: #{method}"
        @frame.view_win.send(method, *args)
      elsif !@command_handler[method.to_sym].nil?
        @command_handler[method.to_sym].each do |m|
          m.call(*args)
        end
      elsif method.to_s[-5, 5] == '_mode'
        mode_name = method.to_s[0..-6]
        mode_class_name = "#{mode_name.capitalize}Mode"
        if Mrbmacs.const_defined?(mode_class_name)
          @current_buffer.mode = Mrbmacs.const_get(mode_class_name).new
          apply_theme_to_mode(@current_buffer.mode, @frame.edit_win, @theme)
        end
      end
    end

    def respond_to_missing?(method, include_private = false)
      method_name = method.to_s
      method_name.upcase.start_with?('SCI_') ||
        @command_handler.key?(method.to_sym) ||
        method_name.end_with?('_mode') ||
        super
    end

    def create_result_buffer(buffer_name)
      result_buffer = Mrbmacs::Buffer.new(buffer_name)
      @frame.view_win.sci_add_refdocument(@current_buffer.docpointer) unless @current_buffer.docpointer.nil?
      @frame.view_win.sci_set_docpointer(nil)
      result_buffer.docpointer = @frame.view_win.sci_get_docpointer
      add_new_buffer(result_buffer)
      @current_buffer = result_buffer
      add_buffer_to_frame(result_buffer)
      update_buffer_mode(result_buffer)
      # @frame.set_theme(@theme)
      apply_theme_to_mode(@current_buffer.mode, @frame.edit_win, @theme)
      @frame.set_buffer_name(buffer_name)
      @frame.edit_win.buffer = @current_buffer
    end

    def setup_result_buffer(buffer_name)
      tmp_win = @frame.edit_win_from_buffer(buffer_name)
      unless tmp_win.nil?
        @frame.switch_window(tmp_win)
        @current_buffer = @frame.edit_win.buffer
        return
      end
      split_window_vertically if @frame.edit_win_list.size == 1
      other_window
      result_buffer = Mrbmacs.get_buffer_from_name(@buffer_list, buffer_name)
      if result_buffer.nil?
        create_result_buffer(buffer_name)
      else
        switch_to_buffer(buffer_name)
      end
    end

    def exec_shell_command_open3(command, directory = nil)
      result = if directory.nil?
                 Open3.capture3(command)
               else
                 Dir.chdir(directory) { Open3.capture3(command) }
               end
      _o, e, s = result
      @frame.view_win.sci_set_text(e)
      @frame.view_win.sci_goto_pos(@frame.view_win.sci_get_length)
      @frame.view_win.sci_insert_text(@frame.view_win.sci_get_length, "\n")
      if s.zero?
        @frame.view_win.sci_insert_text(@frame.view_win.sci_get_length, "#{command} finished")
      else
        @frame.view_win.sci_insert_text(@frame.view_win.sci_get_length,
                                        "#{command} exited with abnormally with code #{s}")
      end
    end

    def exec_shell_command_popen(buffer_name, command, directory = nil)
      io = if directory.nil?
             IO.popen("#{command} 2>&1")
           else
             Dir.chdir(directory) { IO.popen("#{command} 2>&1") }
           end
      add_io_read_event(io) do |app, io_arg|
        ret = io_arg.read(256) unless io_arg.closed?
        result_win = app.frame.edit_win_from_buffer(buffer_name)
        if !ret.nil?
          if app.current_buffer.name == buffer_name
            result_win.sci.sci_insert_text(result_win.sci.sci_get_length, ret)
            result_win.sci.sci_goto_pos(result_win.sci.sci_get_length)
          end
        else
          result_win.sci.sci_insert_text(result_win.sci.sci_get_length, "\n#{command} finished")
          result_win.sci.sci_goto_pos(result_win.sci.sci_get_length)
          app.del_io_read_event(io_arg)
        end
      end
    end

    def exec_shell_command(buffer_name, command, directory = nil)
      setup_result_buffer(buffer_name)
      @current_buffer.docpointer = @frame.view_win.sci_get_docpointer
      @frame.view_win.sci_clear_all
      if Object.const_defined? 'Open3'
        exec_shell_command_open3(command, directory)
      else
        exec_shell_command_popen(buffer_name, command, directory)
      end
    end
  end
end
