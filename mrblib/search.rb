module Mrbmacs
  # Command
  module Command
    describe_command :isearch_forward, 'Search incrementally forward.'

    # Body intentionally empty: every concrete Application (the Terminal and
    # Gui tiers) overrides this. Registered here only so it appears in
    # Command.instance_methods for M-x completion.
    def isearch_forward
    end

    describe_command :isearch_backward, 'Search incrementally backward.'

    def isearch_backward
    end
  end
end
