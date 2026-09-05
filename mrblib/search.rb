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

  # Shared, frontend-independent search primitive used by both
  # ApplicationTerminal (search_terminal.rb) and ApplicationGui
  # (search_gui.rb).
  class Application
    # Search `text` in the current target range; on failure, when `wrap` is
    # true, retry once over the whole buffer (0..length forward, or
    # length..0 backward) before giving up. Returns the found position, or
    # -1 if `text` occurs nowhere in the searched range(s).
    def search_in_target_with_wrap(view, text, backward, wrap)
      found = view.sci_search_in_target(text.bytesize, text)
      if found == -1 && wrap
        view.sci_set_target_start(backward ? view.sci_get_length : 0)
        view.sci_set_target_end(backward ? 0 : view.sci_get_length)
        found = view.sci_search_in_target(text.bytesize, text)
      end
      found
    end

    def isearch_prompt(backward)
      backward ? 'I-search backward: ' : 'I-search: '
    end
  end
end
