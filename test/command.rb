assert('change mode') do
  app = Mrbmacs::TestSupport::Application.new
  test_file = "#{File.dirname(__FILE__)}/test.input"
  app.find_file(test_file)
  assert_equal 'fundamental', app.current_buffer.mode.name
  app.ruby_mode
  assert_equal 'ruby', app.current_buffer.mode.name
end

assert('respond_to_missing?') do
  app = Mrbmacs::TestSupport::Application.new

  # Test responding to existing methods
  assert_true app.respond_to?(:SCI_PRESS)
  assert_true app.respond_to?(:SCI_RELEASE)
  assert_true app.respond_to?(:sci_foobar)
  assert_true app.respond_to?(:ruby_mode)

  # Test non-existent methods
  assert_false app.respond_to?(:non_existent_method)
  assert_false app.respond_to?(:random_method)
end

assert('describe_command normalizes an omitted input schema') do
  name = :test_api_without_arguments
  Mrbmacs::Command.describe_command(
    name,
    'Test API without arguments.',
    { 'handler' => :test_api_without_arguments_handler }
  )

  api = Mrbmacs::Command.metadata[name]['api']
  assert_equal :test_api_without_arguments_handler, api['handler']
  assert_equal(
    {
      'type' => 'object',
      'properties' => {},
      'required' => [],
      'additionalProperties' => false
    },
    api['input_schema']
  )

  Mrbmacs::Command.metadata.delete(name)
end

assert('describe_command normalizes properties without changing its input') do
  name = :test_api_with_arguments
  api_definition = {
    'handler' => :test_api_with_arguments_handler,
    'input_schema' => {
      'properties' => {
        'filename' => { 'type' => 'string' },
        'line' => { 'type' => 'integer' }
      }
    }
  }
  original_definition = {
    'handler' => :test_api_with_arguments_handler,
    'input_schema' => {
      'properties' => {
        'filename' => { 'type' => 'string' },
        'line' => { 'type' => 'integer' }
      }
    }
  }

  Mrbmacs::Command.describe_command(
    name,
    'Test API with arguments.',
    api_definition
  )

  api = Mrbmacs::Command.metadata[name]['api']
  assert_equal :test_api_with_arguments_handler, api['handler']
  assert_equal(
    {
      'type' => 'object',
      'properties' => {
        'filename' => { 'type' => 'string' },
        'line' => { 'type' => 'integer' }
      },
      'required' => ['filename', 'line'],
      'additionalProperties' => false
    },
    api['input_schema']
  )
  assert_equal original_definition, api_definition

  Mrbmacs::Command.metadata.delete(name)
end
