module Mrbmacs
  # Command
  module Command
    describe_command :comment_line, 'Comment or uncomment the current line.'

    def comment_line
      @frame.view_win.sci_begin_undo_action
      line = current_line
      line_text = current_line_text
      pattern1 = Regexp.escape(@current_buffer.mode.start_of_comment)
      pattern2 = Regexp.escape(@current_buffer.mode.end_of_comment)
      start_of_line = @frame.view_win.sci_position_from_line(line) +
                      @frame.view_win.sci_get_line_indentation(line)
      if line_text =~ /^\s*#{pattern1}.*#{pattern2}$/
        @frame.view_win.sci_delete_range(start_of_line, @current_buffer.mode.start_of_comment.size)
        if @current_buffer.mode.end_of_comment.size > 0
          end_of_line = @frame.view_win.sci_get_line_end_position(line)
          @frame.view_win.sci_delete_range(end_of_line - @current_buffer.mode.end_of_comment.size,
                                           @current_buffer.mode.end_of_comment.size)
        end
      else
        @frame.view_win.sci_insert_text(start_of_line, @current_buffer.mode.start_of_comment)
        end_of_line = @frame.view_win.sci_get_line_end_position(line)
        @frame.view_win.sci_insert_text(end_of_line, @current_buffer.mode.end_of_comment)
        @frame.view_win.sci_end_undo_action
      end
    end

    describe_command :uncomment_line, 'Uncomment the current line.'

    def uncomment_line
      @frame.view_win.sci_begin_undo_action
      line = current_line
      line_text = current_line_text
      pattern1 = Regexp.escape(@current_buffer.mode.start_of_comment)
      pattern2 = Regexp.escape(@current_buffer.mode.end_of_comment)
      if line_text =~ /^\s*#{pattern1}.*#{pattern2}$/
        end_of_line = @frame.view_win.sci_get_line_end_position(line)
        if @current_buffer.mode.end_of_comment.size > 0
          @frame.view_win.sci_delete_range(end_of_line - @current_buffer.mode.end_of_comment.size,
                                           @current_buffer.mode.end_of_comment.size)
        end
        start_of_line = @frame.view_win.sci_position_from_line(line) +
                        @frame.view_win.sci_get_line_indentation(line)
        @frame.view_win.sci_delete_range(start_of_line, @current_buffer.mode.start_of_comment.size)
      end
      @frame.view_win.sci_end_undo_action
    end

  end
end
