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

The API metadata currently contains `input_schema`, a JSON Schema describing
the arguments accepted by the externally exposed command.

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
        }
      }
    )
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
        }
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

`describe_command` only records metadata; it does not expose or dispatch the
command by itself. Consumers such as `mruby-mrbmacs-agent` decide how
API-enabled commands are listed, validated, and invoked.
