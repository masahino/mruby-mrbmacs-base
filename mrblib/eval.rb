module Mrbmacs
  # Command
  module Command
    describe_command :eval_last_exp, 'Evaluate the expression before point.'

    def eval_last_exp
      text, pos = @frame.view_win.sci_get_curline
      ret = nil
      begin
        ret = instance_eval(text[0..pos - 1])
      rescue SyntaxError, StandardError => e
        @logger.error e.to_s
        ret = e.to_s
      end
      output = ret.to_s
      @frame.view_win.sci_newline
      @frame.view_win.sci_addtext(output.bytesize, output)
      @frame.view_win.sci_newline
    end

    describe_command :eval_buffer, 'Evaluate the current buffer as Ruby code.'

    def eval_buffer
      all_text = @frame.view_win.sci_get_text(@frame.view_win.sci_get_length + 1)
      ret = nil
      begin
        ret = instance_eval(all_text)
      rescue SyntaxError, StandardError => e
        @logger.error e.to_s
      end
      @logger.debug ret
    end

  end
end
