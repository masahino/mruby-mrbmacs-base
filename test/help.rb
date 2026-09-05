assert('list_commands has description and API metadata') do
  metadata = Mrbmacs::Command.metadata[:list_commands]

  assert_equal 'List available editor commands.', metadata['description']
  assert_equal({}, metadata['api']['input_schema']['properties'])
  assert_equal([], metadata['api']['input_schema']['required'])
  assert_false metadata['api']['input_schema']['additionalProperties']
  assert_equal :list_commands_api, metadata['api']['handler']
end

assert('isearch_forward, isearch_backward, replace_string and query_replace are described commands') do
  %i[isearch_forward isearch_backward replace_string query_replace].each do |name|
    metadata = Mrbmacs::Command.metadata[name]

    assert_false metadata.nil?
    assert_false metadata['description'].nil?
    assert_true Mrbmacs::Command.instance_methods.include?(name)
  end
end

assert('internal methods are not editor commands') do
  commands = Mrbmacs::Command.instance_methods

  assert_false commands.include?(:insert)
  assert_false commands.include?(:vc_refresh_gutter)
  assert_nil Mrbmacs::Command.metadata[:insert]
  assert_nil Mrbmacs::Command.metadata[:vc_refresh_gutter]
end

assert('command_information includes commands with and without metadata') do
  app = Mrbmacs::TestSupport::Application.new
  app.instance_variable_set(
    :@command_list,
    ['list_commands', 'find_file', 'describe_bindings']
  )

  assert_equal(
    [
      {
        'name' => 'describe-bindings',
        'description' => 'List the current key bindings.',
        'api' => false
      },
      { 'name' => 'find-file', 'description' => 'Open a file.', 'api' => false },
      {
        'name' => 'list-commands',
        'description' => 'List available editor commands.',
        'api' => true
      }
    ],
    app.command_information
  )
end

assert('format_commands shows descriptions when available') do
  app = Mrbmacs::TestSupport::Application.new
  app.instance_variable_set(
    :@command_list,
    ['list_commands', 'find_file', 'describe_bindings']
  )
  app.define_singleton_method(:effective_keybindings) do
    {
      'C-x C-f' => 'find_file',
      'C-c f' => 'find-file',
      'C-x' => 'prefix',
      'C-p' => Scintilla::SCI_LINEUP
    }
  end

  assert_equal(
    "Available commands\n\n" \
    "describe-bindings  List the current key bindings.\n" \
    "find-file          Open a file.  (C-c f, C-x C-f)\n" \
    "list-commands      List available editor commands.  [API]\n",
    app.format_commands
  )
end

assert('format_commands marks a missing description') do
  app = Mrbmacs::TestSupport::Application.new
  app.instance_variable_set(:@command_list, ['unregistered_command'])
  app.define_singleton_method(:effective_keybindings) { {} }

  assert_equal(
    "Available commands\n\nunregistered-command  (no description)\n",
    app.format_commands
  )
end

assert('command_keybindings includes only string command bindings') do
  app = Mrbmacs::TestSupport::Application.new
  app.define_singleton_method(:effective_keybindings) do
    {
      'C-x C-f' => 'find_file',
      'C-c f' => 'find-file',
      'C-x' => 'prefix',
      'C-p' => Scintilla::SCI_LINEUP
    }
  end

  assert_equal(
    { 'find_file' => ['C-c f', 'C-x C-f'] },
    app.command_keybindings
  )
end

assert('format_key_bindings shows effective bindings in key order') do
  app = Mrbmacs::TestSupport::Application.new
  app.current_buffer.mode = Mrbmacs::Mode.new
  app.current_buffer.mode.name = 'test'
  app.define_singleton_method(:effective_keybindings) do
    {
      'M-x' => 'execute_extended_command',
      'C-x' => 'prefix',
      'C-p' => Scintilla::SCI_LINEUP,
      'C-x C-f' => 'find_file'
    }
  end
  app.define_singleton_method(:scintilla_command_names) do
    { Scintilla::SCI_LINEUP => 'SCI_LINEUP' }
  end

  assert_equal(
    "Key bindings for test mode\n\n" \
    "C-p      SCI_LINEUP\n" \
    "C-x C-f  find-file\n" \
    "M-x      execute-extended-command\n",
    app.format_key_bindings
  )
end

assert('key_binding_action_name falls back for an unknown Scintilla command') do
  app = Mrbmacs::TestSupport::Application.new

  assert_equal 'Scintilla command 999999', app.key_binding_action_name(999_999, {})
end

assert('scintilla_command_names includes Scintilla commands') do
  app = Mrbmacs::TestSupport::Application.new

  assert_equal 'SCI_LINEUP', app.scintilla_command_names[Scintilla::SCI_LINEUP]
end

assert('describe_bindings displays a read-only Bindings buffer') do
  app = Mrbmacs::TestSupport::Application.new
  buffer_names = []
  messages = []
  app.define_singleton_method(:format_key_bindings) { "bindings\n" }
  app.define_singleton_method(:setup_result_buffer) do |buffer_name|
    buffer_names << buffer_name
  end
  view = app.frame.view_win
  view.define_singleton_method(:sci_set_read_only) do |read_only|
    messages << [:read_only, read_only]
  end
  view.define_singleton_method(:sci_set_text) do |text|
    messages << [:text, text]
  end
  view.define_singleton_method(:sci_set_save_point) do
    messages << [:save_point]
  end
  view.define_singleton_method(:sci_goto_pos) do |position|
    messages << [:goto_pos, position]
  end

  app.describe_bindings

  assert_equal ['*Bindings*'], buffer_names
  assert_equal [
    [:read_only, 0],
    [:text, "bindings\n"],
    [:save_point],
    [:read_only, 1],
    [:goto_pos, 0]
  ], messages
end


assert('list_commands displays a read-only Commands buffer') do
  app = Mrbmacs::TestSupport::Application.new
  buffer_names = []
  messages = []
  app.define_singleton_method(:format_commands) { "commands\n" }
  app.define_singleton_method(:setup_result_buffer) do |buffer_name|
    buffer_names << buffer_name
  end
  view = app.frame.view_win
  view.define_singleton_method(:sci_set_read_only) do |read_only|
    messages << [:read_only, read_only]
  end
  view.define_singleton_method(:sci_set_text) do |text|
    messages << [:text, text]
  end
  view.define_singleton_method(:sci_set_save_point) do
    messages << [:save_point]
  end
  view.define_singleton_method(:sci_goto_pos) do |position|
    messages << [:goto_pos, position]
  end

  app.list_commands

  assert_equal ['*Commands*'], buffer_names
  assert_equal [
    [:read_only, 0],
    [:text, "commands\n"],
    [:save_point],
    [:read_only, 1],
    [:goto_pos, 0]
  ], messages
end
