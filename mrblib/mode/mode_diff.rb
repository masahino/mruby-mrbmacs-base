module Mrbmacs
  class DiffMode < Mode
    def self.hunk_header?(line)
      line.start_with?('@@ ')
    end

    def initialize
      super
      @name = 'diff'
      @lexer_profile = DIFF_LEXER_PROFILE
      add_keybind('M-n', 'diff_next_hunk')
      add_keybind('M-p', 'diff_previous_hunk')
    end
  end

  module Command
    describe_command :diff_next_hunk, 'Move to the next diff hunk.'

    def diff_next_hunk
      move_to_diff_hunk(:next)
    end

    describe_command :diff_previous_hunk, 'Move to the previous diff hunk.'

    def diff_previous_hunk
      move_to_diff_hunk(:previous)
    end

    private

    def move_to_diff_hunk(direction)
      unless @current_buffer.mode.name == 'diff'
        message 'Not in a diff buffer'
        return
      end

      win = @frame.view_win
      current_line = win.sci_line_from_position(win.sci_get_current_pos)
      lines = if direction == :next
                ((current_line + 1)...win.sci_get_line_count).to_a
              else
                (0...current_line).to_a.reverse
              end
      target_line = lines.find { |line| DiffMode.hunk_header?(win.sci_get_line(line)) }
      if target_line.nil?
        message(direction == :next ? 'No next hunk' : 'No previous hunk')
        return
      end

      win.sci_goto_pos(win.sci_position_from_line(target_line))
      win.sci_scroll_caret
    end
  end
end
