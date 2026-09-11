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
      remember_clipboard(win)
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
      remember_clipboard(win)
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
      remember_clipboard(win)
    end

    def remember_clipboard(win)
      @clipboard_text = win.get_clipboard if win.respond_to?(:get_clipboard)
    end
    private :remember_clipboard

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
      return :cancelled unless prepare_to_exit

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
      return if @mark_pos.nil?

      each_rectangle_line do |start_pos, end_pos, width|
        @frame.view_win.sci_delete_range(start_pos, end_pos - start_pos)
        @frame.view_win.sci_insert_text(start_pos, ' ' * width)
      end
    end

    describe_command :delete_rectangle, 'Delete the selected rectangle.'

    def delete_rectangle
      return if @mark_pos.nil?

      each_rectangle_line do |start_pos, end_pos, _width|
        @frame.view_win.sci_delete_range(start_pos, end_pos - start_pos)
      end
    end

    describe_command :recenter, 'Center the current line in the window.'

    def recenter
      @frame.view_win.sci_vertical_centre_caret
    end

    describe_command :downcase_word, 'Convert the following word to lowercase.'

    def downcase_word
      current_pos = @frame.view_win.sci_get_current_pos
      wordend_pos = word_end_pos(current_pos)

      return if wordend_pos <= current_pos

      word = @frame.view_win.sci_get_textrange(current_pos, wordend_pos)
      @frame.view_win.sci_delete_range(current_pos, word.bytesize)
      @frame.view_win.sci_add_text(word.bytesize, word.downcase)
    end

    describe_command :upcase_word, 'Convert the following word to uppercase.'

    def upcase_word
      current_pos = @frame.view_win.sci_get_current_pos
      wordend_pos = word_end_pos(current_pos)

      return if wordend_pos <= current_pos

      word = @frame.view_win.sci_get_textrange(current_pos, wordend_pos)
      @frame.view_win.sci_delete_range(current_pos, word.bytesize)
      @frame.view_win.sci_add_text(word.bytesize, word.upcase)
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

    # The rectangle marked by @mark_pos and point, as
    # [first_line, last_line, first_column, last_column].
    def marked_rectangle
      anchor_line, anchor_column = line_col_from_pos(@mark_pos)
      caret_line, caret_column = line_col_from_pos(get_current_pos)
      [anchor_line, caret_line].sort + [anchor_column, caret_column].sort
    end

    # The byte range of every line of the marked rectangle, bottom line first,
    # together with the column width of the rectangle.
    #
    # The ranges come from SCI_FINDCOLUMN, which is document based. Scintilla's
    # own rectangular selection is defined in screen X coordinates instead:
    # both SCI_REPLACERECTANGULAR and SCI_SETRECTANGULARSELECTION* go through
    # Editor::SetRectangularRange, so they need a laid out view and answer
    # differently in every frontend.
    #
    # Bottom line first, so that editing one line cannot shift the byte
    # positions of the lines still to come.
    def rectangle_line_ranges
      win = @frame.view_win
      first_line, last_line, first_column, last_column = marked_rectangle
      ranges = []
      line = last_line
      while line >= first_line
        ranges.push [win.sci_find_column(line, first_column), win.sci_find_column(line, last_column)]
        line -= 1
      end
      [ranges, last_column - first_column]
    end

    # Yields the byte range (start_pos, end_pos) and the column width of every
    # line of the marked rectangle as a single undo action, then drops the mark
    # and leaves point at the top left corner of the rectangle.
    def each_rectangle_line
      win = @frame.view_win
      ranges, width = rectangle_line_ranges
      top_left = ranges.last[0]
      win.sci_begin_undo_action
      ranges.each { |start_pos, end_pos| yield start_pos, end_pos, width }
      win.sci_end_undo_action
      win.sci_set_empty_selection(top_left)
      @mark_pos = nil
    end
  end

  class Application
    def prepare_to_exit
      return true if @exit_prepared

      buffers = @buffer_list.select { |buffer| buffer.name !~ /^\*.*\*$/ }
      discard_all = false

      buffers.each do |buffer|
        next unless @buffer_list.include?(buffer)

        if discard_all
          close_buffer(buffer)
          next
        end

        result = process_buffer_close(buffer, true)
        return false if result == :cancelled
        next unless result == :discard_all

        return false unless @frame.y_or_n(
          'Discard changes in all remaining buffers and exit?'
        )

        close_buffer(buffer)
        discard_all = true
      end

      before_save_buffers_kill_terminal(self)
      @exit_prepared = true
    end
  end
end
