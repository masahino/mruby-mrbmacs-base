assert('search_project_core returns structured literal matches and skips excluded directories') do
  tmp_directory = ENV['TMPDIR'] || '/tmp'
  root = File.join(tmp_directory, "mrbmacs-project-search-test-#{$$}-#{Time.now.to_i}")
  lib_directory = File.join(root, 'lib')
  build_directory = File.join(root, 'build')
  main_file = File.join(root, 'main.txt')
  helper_file = File.join(lib_directory, 'helper.txt')
  generated_file = File.join(build_directory, 'generated.txt')

  begin
    Dir.mkdir(root)
    Dir.mkdir(lib_directory)
    Dir.mkdir(build_directory)
    File.open(main_file, 'w') { |file| file.write("definition\ntarget_word appears twice: target_word\n") }
    File.open(helper_file, 'w') { |file| file.write("helper\ntarget_word\n") }
    File.open(generated_file, 'w') { |file| file.write("target_word in an excluded directory\n") }
    stats = {}

    results = Mrbmacs.search_project_core('target_word', root, stats)

    assert_equal 2, results.length
    assert_equal 2, stats['files']
    assert_equal ['file', 'line', 'text'], results[0].keys.sort
    assert_true results.all? { |result| !result['file'].include?('/build/') }
    assert_equal [2, 2], results.map { |result| result['line'] }.sort
  ensure
    [main_file, helper_file, generated_file].each do |file|
      File.delete(file) if File.exist?(file)
    end
    [lib_directory, build_directory, root].each do |directory|
      Dir.rmdir(directory) if Dir.exist?(directory)
    end
  end
end

assert('search_project uses only the Scintilla word as the initial query') do
  app = Mrbmacs::TestSupport::Application.new
  view = app.frame.view_win
  received_default = nil
  displayed = nil
  app.project.update(Dir.pwd)
  view.define_singleton_method(:sci_get_current_pos) { 8 }
  view.define_singleton_method(:sci_word_start_position) do |position, only_word_characters|
    assert_equal 8, position
    assert_true only_word_characters
    4
  end
  view.define_singleton_method(:sci_word_end_position) do |position, only_word_characters|
    assert_equal 8, position
    assert_true only_word_characters
    15
  end
  view.define_singleton_method(:sci_get_text_range) do |start_position, end_position|
    assert_equal 4, start_position
    assert_equal 15, end_position
    'target_word'
  end
  app.frame.define_singleton_method(:echo_gets) do |_prompt, default|
    received_default = default
    nil
  end
  app.define_singleton_method(:display_project_search_results) do |*args|
    displayed = args
  end

  app.search_project

  assert_equal 'target_word', received_default
  assert_nil displayed
end

assert('search_project_word_at_cursor returns empty text outside a word') do
  app = Mrbmacs::TestSupport::Application.new
  view = app.frame.view_win
  view.define_singleton_method(:sci_get_current_pos) { 3 }
  view.define_singleton_method(:sci_word_start_position) { |_position, _only_word_characters| 3 }
  view.define_singleton_method(:sci_word_end_position) { |_position, _only_word_characters| 3 }

  assert_equal '', app.search_project_word_at_cursor
end

assert('display_project_search_results writes summary and relative result paths') do
  app = Mrbmacs::TestSupport::Application.new
  root = File.expand_path('/work/project')
  app.project.update(root)
  app.current_buffer.mode = Mrbmacs::ProjectsearchMode.new
  app.define_singleton_method(:setup_result_buffer) { |_buffer_name| nil }
  calls = []
  view = app.frame.view_win
  view.define_singleton_method(:sci_set_read_only) { |value| calls << [:read_only, value] }
  view.define_singleton_method(:sci_set_text) { |text| calls << [:text, text] }
  view.define_singleton_method(:sci_set_save_point) { calls << [:save_point] }
  view.define_singleton_method(:sci_goto_pos) { |position| calls << [:goto_pos, position] }

  app.display_project_search_results(
    'target_word',
    [{ 'file' => "#{root}/lib/helper.txt", 'line' => 2, 'text' => 'target_word' }],
    0.1254
  )

  output = calls.find { |call| call[0] == :text }[1]
  assert_true output.include?("Matches: 1\n")
  assert_true output.include?("Elapsed: 0.125 sec\n")
  assert_true output.include?("lib/helper.txt:2:target_word\n")
  assert_equal 'target_word', app.current_buffer.mode.pattern
  assert_equal root, app.current_buffer.mode.root_directory
  assert_equal [[:read_only, 0], [:text, output], [:save_point], [:read_only, 1], [:goto_pos, 0]], calls
end

assert('ProjectsearchMode opens a relative result from its project root') do
  app = Mrbmacs::TestSupport::Application.new
  mode = Mrbmacs::ProjectsearchMode.new
  mode.root_directory = '/work/project'
  app.current_buffer.mode = mode
  app.frame.view_win.define_singleton_method(:sci_get_curline) { ['lib/example.rb:12:target_word'] }
  app.frame.view_win.define_singleton_method(:sci_position_from_line) do |line|
    assert_equal 11, line
    123
  end
  app.frame.view_win.define_singleton_method(:sci_goto_pos) do |position|
    assert_equal 123, position
  end
  app.frame.edit_win_list << app.frame.edit_win
  app.define_singleton_method(:other_window) { nil }
  opened_file = nil
  app.define_singleton_method(:find_file) { |file| opened_file = file }

  app.project_search_open_file

  assert_equal '/work/project/lib/example.rb', opened_file
end

assert('ModeManager selects ProjectsearchMode for the result buffer') do
  mode = Mrbmacs::ModeManager.set_mode_by_filename('*Project Search*')
  assert_equal 'project-search', mode.name
  assert_equal 'project_search_open_file', mode.keymap['Enter']
end
