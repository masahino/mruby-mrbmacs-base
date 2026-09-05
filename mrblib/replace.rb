module Mrbmacs
  # Command
  module Command
    describe_command :replace_string, 'Replace occurrences of a string from point.'

    # Body intentionally empty: every concrete Application (the Terminal and
    # Gui tiers) overrides this. Registered here only so it appears in
    # Command.instance_methods for M-x completion.
    def replace_string
    end

    describe_command :query_replace, 'Replace text interactively with confirmation.'

    def query_replace
    end
  end
end
