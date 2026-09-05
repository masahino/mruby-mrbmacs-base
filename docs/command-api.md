# Command metadata API

Editor commands are public instance methods of `Mrbmacs::Command`. Use
`describe_command` next to a command definition to attach a description and,
when applicable, an external API input schema.

## `describe_command`

```ruby
describe_command(method_name, description, api = nil)
```

- `method_name` is the command's Ruby method name as a Symbol.
- `description` is the human-readable command description.
- `api` is optional metadata for exposing the command through an external API.
  Omit it for commands that must remain editor-only.

The API metadata contains:

- `input_schema`, a JSON Schema describing the accepted arguments.
- `handler`, the `Application` method that receives those arguments and returns
  a structured result.

## Command without arguments

```ruby
module Mrbmacs
  module Command
    def list_commands
      # Human-facing command implementation
    end

    describe_command(
      :list_commands,
      'List available editor commands.',
      {
        'input_schema' => {
          'type' => 'object',
          'properties' => {},
          'required' => [],
          'additionalProperties' => false
        },
        'handler' => :list_commands_api
      }
    )
  end

  class Application
    def list_commands_api(arguments)
      raise ArgumentError unless arguments.empty?

      commands = command_information
      {
        'commands' => commands,
        'total_commands' => commands.length
      }
    end
  end
end
```

This schema describes an object that accepts no properties.

## Command with arguments

```ruby
module Mrbmacs
  module Command
    def find_file(path)
      # Human-facing command implementation
    end

    describe_command(
      :find_file,
      'Open a file.',
      {
        'input_schema' => {
          'type' => 'object',
          'properties' => {
            'path' => {
              'type' => 'string',
              'description' => 'Path of the file to open.'
            }
          },
          'required' => ['path'],
          'additionalProperties' => false
        },
        'handler' => :find_file_api
      }
    )
  end
end
```

The schema fields have the following meanings:

- `type: 'object'` means the API arguments must be passed as an object (a Ruby
  `Hash` after decoding).
- `properties` defines the accepted arguments. Each key is an argument name and
  its value describes that argument. In the example, `path` must be a string.
- `required` lists properties that must be present. Properties defined in
  `properties` but omitted from `required` are optional.
- `additionalProperties: false` rejects argument names not declared in
  `properties`. This catches misspellings and prevents unsupported input from
  being silently accepted.
- `handler` names the API-specific entry point. It may validate arguments and
  return structured data without invoking the human-facing UI command.

`describe_command` records the schema and API handler together. A consumer such
as `mruby-mrbmacs-agent` lists API-enabled commands from this metadata and
dispatches a tool call to the declared handler. The human-facing command and
the API handler may share a core helper while keeping their UI and structured
result responsibilities separate.
