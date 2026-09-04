module Mrbmacs
  # Help commands
  module Command
    describe_command(
      :list_commands,
      'List available editor commands.',
      {
        'input_schema' => {
          'type' => 'object',
          'properties' => {},
          'required' => [],
          'additionalProperties' => false
        }
      }
    )

    def list_commands
      text = format_commands
      setup_result_buffer('*Commands*')
      @frame.view_win.sci_set_read_only(0)
      @frame.view_win.sci_set_text(text)
      @frame.view_win.sci_set_save_point
      @frame.view_win.sci_set_read_only(1)
      @frame.view_win.sci_goto_pos(0)
    end

    describe_command :describe_bindings, 'List the current key bindings.'

    def describe_bindings
      text = format_key_bindings
      setup_result_buffer('*Bindings*')
      @frame.view_win.sci_set_read_only(0)
      @frame.view_win.sci_set_text(text)
      @frame.view_win.sci_set_save_point
      @frame.view_win.sci_set_read_only(1)
      @frame.view_win.sci_goto_pos(0)
    end

  end

  # Application helpers for help commands
  class Application
    def command_information
      @command_list.map do |command|
        metadata = Command.metadata[command.to_sym]
        {
          'name' => command.tr('_', '-'),
          'description' => metadata.nil? ? nil : metadata['description'],
          'api' => !metadata.nil? && !metadata['api'].nil?
        }
      end.sort { |a, b| a['name'] <=> b['name'] }
    end

    def format_commands
      commands = command_information
      keybindings = command_keybindings
      name_width = commands.map { |command| command['name'].length }.max || 0
      lines = commands.map do |command|
        description = command['description']
        description = '(no description)' if description.nil? || description.empty?
        line = "#{command['name'].ljust(name_width)}  #{description}"
        keys = keybindings[command['name'].tr('-', '_')]
        line += "  (#{keys.join(', ')})" unless keys.nil?
        line += '  [API]' if command['api']
        line
      end
      (["Available commands", ''] + lines).join("\n") + "\n"
    end

    def command_keybindings
      bindings = {}
      effective_keybindings.each do |key, action|
        next unless action.is_a?(String)

        command = action.tr('-', '_')
        next if command == 'prefix'

        bindings[command] ||= []
        bindings[command] << key
      end
      bindings.each_value { |keys| keys.sort! }
      bindings
    end

    def scintilla_command_names
      command_names = {}
      names = Scintilla.constants.map(&:to_s).select do |name|
        name.start_with?('SCI_')
      end.sort
      names.each do |name|
        value = Scintilla.const_get(name)
        command_names[value] ||= name if value.is_a?(Integer)
      end
      command_names
    end

    def key_binding_action_name(action, command_names = scintilla_command_names)
      if action.is_a?(Integer)
        command_names[action] || "Scintilla command #{action}"
      else
        action.to_s.tr('_', '-')
      end
    end

    def format_key_bindings
      bindings = effective_keybindings.reject do |_key, command|
        command == 'prefix'
      end
      keys = bindings.keys.sort
      key_width = keys.map(&:length).max || 0
      command_names = scintilla_command_names
      lines = keys.map do |key|
        "#{key.ljust(key_width)}  #{key_binding_action_name(bindings[key], command_names)}"
      end
      (["Key bindings for #{@current_buffer.mode.name} mode", ''] + lines).join("\n") + "\n"
    end
  end
end
