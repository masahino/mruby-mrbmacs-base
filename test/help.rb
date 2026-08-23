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
