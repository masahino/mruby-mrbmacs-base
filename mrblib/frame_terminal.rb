module Mrbmacs
  # Shared logic for the terminal frontends' (curses, termbox) minibuffer
  # confirmation prompt. Not named `y_or_n` itself, and not relied on
  # through inheritance: Mrbmacs::Frame is also reopened by gtk (a
  # callback-driven frontend, unrelated to this), so each terminal frontend
  # keeps its own thin `y_or_n` that just calls this by name, rather than
  # letting method resolution pick a Frame-level override implicitly.
  class Frame
    def read_choice_terminal(prompt, choices)
      $stderr.puts prompt if $DEBUG
      @echo_win.sci_clear_all
      echo_set_prompt(prompt)
      loop do
        _ret, key = waitkey(@echo_win)
        key_str = strfkey(key)
        return :cancel if key_str == 'C-g'

        choice = choices[key_str.downcase]
        return choice unless choice.nil?
      end
    ensure
      echo_set_prompt('')
    end

    def y_or_n_terminal(prompt)
      read_choice_terminal(prompt, { 'y' => true, 'n' => false }) == true
    end
  end
end
