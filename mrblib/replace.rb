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

  # Shared, frontend-independent replace-loop primitives used by both
  # ApplicationTerminal (replace_terminal.rb) and ApplicationGui
  # (replace_gui.rb).
  class Application
    def with_undo_action
      @frame.view_win.sci_begin_undo_action
      yield
    ensure
      @frame.view_win.sci_end_undo_action
    end

    # Replace every remaining occurrence of search_text from start_pos to
    # the end of the buffer. Returns the number of replacements made.
    def replace_all_from(start_pos, search_text, replacement_text)
      view = @frame.view_win
      count = 0
      with_undo_action do
        next_pos = start_pos
        loop do
          view.sci_set_target_start(next_pos)
          view.sci_set_target_end(view.sci_get_length)
          break if view.sci_search_in_target(search_text.bytesize, search_text) == -1

          view.sci_replace_target(replacement_text.bytesize, replacement_text)
          count += 1
          next_pos = view.sci_get_target_end
        end
      end
      count
    end

    def replace_summary(count)
      "Replaced #{count} occurrence#{count == 1 ? '' : 's'}"
    end

    def query_replace_prompt(search_text, replacement_text)
      "Query replacing #{search_text} with #{replacement_text}: (y, n, !, q) "
    end
  end
end
