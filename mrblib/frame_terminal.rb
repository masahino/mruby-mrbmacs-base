module Mrbmacs
  # Shared logic for the terminal frontends' (curses, termbox) minibuffer
  # confirmation prompt. Not named `y_or_n` itself, and not relied on
  # through inheritance: Mrbmacs::Frame is also reopened by gtk (a
  # callback-driven frontend, unrelated to this), so each terminal frontend
  # keeps its own thin `y_or_n` that just calls this by name, rather than
  # letting method resolution pick a Frame-level override implicitly.
  class Frame
    def y_or_n_terminal(prompt)
      $stderr.puts prompt if $DEBUG
      @echo_win.sci_clear_all
      echo_set_prompt(prompt)
      _ret, key = waitkey(@echo_win)
      key_str = strfkey(key)
      echo_set_prompt('')
      key_str == 'Y' || key_str == 'y'
    end
  end
end
