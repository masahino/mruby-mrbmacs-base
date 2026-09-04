module Mrbmacs
  # Command
  module Command
    describe_command :set_mark, 'Set the mark at the current position.'

    def set_mark
      @mark_pos = @frame.view_win.sci_get_current_pos
      @frame.view_win.sci_set_anchor(@mark_pos)
      @frame.view_win.sci_set_selection_mode(0) if @frame.view_win.sci_get_move_extends_selection == 0
    end

    describe_command :copy_region, 'Copy the region between point and mark.'

    def copy_region
      win = @frame.view_win
      current_pos = win.sci_get_current_pos

      win.sci_copy_range(@mark_pos, current_pos)
      win.sci_set_empty_selection(current_pos)
      @mark_pos = nil
    end

    describe_command :cut_region, 'Cut the region between point and mark.'

    def cut_region
      return if @mark_pos.nil?

      win = @frame.view_win
      current_pos = win.sci_get_current_pos

      win.sci_goto_pos(current_pos)
      win.sci_copy_range(@mark_pos, current_pos)
      win.sci_delete_range(@mark_pos, current_pos - @mark_pos)
      @mark_pos = nil
    end

    describe_command :yank, 'Insert the most recently copied or cut text.'

    def yank
      @frame.view_win.sci_paste
    end

    describe_command :kill_line, 'Cut text from point to the end of the line.'

    def kill_line
      win = @frame.view_win
      current_pos = win.sci_get_current_pos

      line = win.sci_line_from_position(current_pos)
      line_end_pos = win.sci_get_line_end_position(line)
      if win.sci_get_line(line) != "\n"
        win.sci_copy_range(current_pos, line_end_pos)
        win.sci_delete_range(current_pos, line_end_pos - current_pos)
      else
        win.sci_line_cut
      end
    end

    describe_command :isearch_backward, 'Search incrementally backward.'

    def isearch_backward
      # isearch_backward
    end

    describe_command :isearch_forward, 'Search incrementally forward.'

    def isearch_forward
      # isearch_forward
    end

    describe_command :indent, 'Indent the current line or complete the active candidate.'

    def indent
      win = @frame.view_win

      if win.sci_autoc_active
        # current = win.sci_autoc_get_current
        win.sci_autoc_complete
        # win.sci_linedown
        # win.sci_vchome if current == win.sci_autoc_get_current
      else
        current_pos = win.sci_get_current_pos

        line = win.sci_line_from_position(current_pos)
        indent = @current_buffer.mode.get_indent(win)
        win.sci_set_line_indentation(line, indent)
        win.sci_vchome if win.sci_get_column(current_pos) < indent
      end
    end

    describe_command :beginning_of_line, 'Move point to the beginning of the line.'

    def beginning_of_line
      @frame.view_win.sci_home
    end

    describe_command :end_of_line, 'Move point to the end of the line.'

    def end_of_line
      @frame.view_win.sci_lineend
    end

    describe_command :beginning_of_buffer, 'Move point to the beginning of the buffer.'

    def beginning_of_buffer
      @frame.view_win.sci_document_start
    end

    describe_command :end_of_buffer, 'Move point to the end of the buffer.'

    def end_of_buffer
      @frame.view_win.sci_document_end
    end

    describe_command :newline, 'Insert a newline.'

    def newline
      if @frame.view_win.sci_autoc_active
        # win.sci_autoc_cancel
        @frame.view_win.sci_tab
      else
        @frame.view_win.sci_new_line
      end
    end

    describe_command :save_buffers_kill_terminal, 'Exit mrbmacs.'

    def save_buffers_kill_terminal
      before_save_buffers_kill_terminal(self)
      @frame.exit
      exit
    end

    describe_command :keyboard_quit, 'Cancel the current editor operation.'

    def keyboard_quit
      @frame.view_win.sci_set_empty_selection(get_current_pos)
      @frame.view_win.sci_autoc_cancel
      @frame.view_win.sci_calltip_cancel
      @mark_pos = nil
    end

    describe_command :clear_rectangle, 'Replace the selected rectangle with spaces.'

    def clear_rectangle
      @frame.view_win.sci_set_selection_mode(1)
      return if @mark_pos.nil?

      @frame.view_win.sci_set_anchor(@mark_pos)
      anchor_x = @frame.view_win.sci_get_column(@mark_pos)
      anchor_y = @frame.view_win.sci_line_from_position(@mark_pos)
      current_x = @frame.view_win.sci_get_column(get_current_pos)
      current_y = @frame.view_win.sci_line_from_position(get_current_pos)
      width = (current_x - anchor_x).abs
      lines = (current_y - anchor_y).abs + 1
      replaced_text = Array.new(lines, ' ' * width).join("\n")
      @frame.view_win.sci_replace_rectangular(replaced_text.length, replaced_text)
      @mark_pos = nil
    end

    describe_command :delete_rectangle, 'Delete the selected rectangle.'

    def delete_rectangle
      @frame.view_win.sci_set_selection_mode(1)
      return if @mark_pos.nil?

      @frame.view_win.sci_set_anchor(@mark_pos)
      @frame.view_win.sci_replace_sel(nil, '')
      @mark_pos = nil
    end

    describe_command :recenter, 'Center the current line in the window.'

    def recenter
      @frame.view_win.sci_vertical_centre_caret
    end

    describe_command :downcase_word, 'Convert the following word to lowercase.'

    def downcase_word
      current_pos = @frame.view_win.sci_get_current_pos
      wordend_pos = @frame.view_win.sci_word_end_position(current_pos, true)

      return if wordend_pos <= current_pos

      word = @frame.view_win.sci_get_textrange(current_pos, wordend_pos)
      @frame.view_win.sci_delete_range(current_pos, word.length)
      @frame.view_win.sci_add_text(word.length, word.downcase)
    end

    describe_command :upcase_word, 'Convert the following word to uppercase.'

    def upcase_word
      current_pos = @frame.view_win.sci_get_current_pos
      wordend_pos = word_end_pos(current_pos)
      return if wordend_pos <= current_pos

      word = @frame.view_win.sci_get_textrange(current_pos, wordend_pos)
      @frame.view_win.sci_delete_range(current_pos, word.length)
      @frame.view_win.sci_add_text(word.length, word.upcase)
    end

  end

  # Application
  class Application
    def word_end_pos(start_pos)
      (start_pos..@frame.view_win.sci_get_length).each do |p|
        end_pos = @frame.view_win.sci_word_end_position(p, true)
        return end_pos if end_pos != p
      end
      start_pos
    end

    def line_col_from_pos(pos)
      col = @frame.view_win.sci_get_column(pos)
      line = @frame.view_win.sci_line_from_position(pos)
      [line, col]
    end

    def get_current_line_col
      line_col_from_pos(@frame.view_win.sci_get_current_pos)
    end

    def current_line_text
      pos = @frame.view_win.sci_get_current_pos
      line = @frame.view_win.sci_line_from_position(pos)
      @frame.view_win.sci_get_line(line)
    end

    def current_col
      @frame.view_win.sci_get_column(@frame.view_win.sci_get_current_pos)
    end

    def current_line
      @frame.view_win.sci_line_from_position(@frame.view_win.sci_get_current_pos)
    end

    def get_current_pos
      @frame.view_win.sci_get_current_pos
    end
  end
end
