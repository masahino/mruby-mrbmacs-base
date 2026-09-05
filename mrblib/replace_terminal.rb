module Mrbmacs
  # Query-replace / replace-string for the terminal frontends (curses,
  # termbox): a blocking loop, since the terminal frontend owns its own
  # event loop. Confirmation keys during query-replace (y/n/!/q/C-g) are
  # read directly via @frame.waitkey/strfkey, mirroring the key set
  # ApplicationGui's query_replace_key_press supports.
  class ApplicationTerminal < Application
    def replace_string(str = nil, newstr = nil, query = false)
      if str.nil? || newstr.nil?
        @frame.echo_win.sci_clear_all
        str = @frame.echo_gets('Replace string: ', '')
        return if str.nil?

        newstr = @frame.echo_gets("Replace string #{str} with: ", '')
        return if newstr.nil?
      end

      if query
        query_replace_from(@frame.view_win.sci_get_current_pos, str, newstr)
      else
        count = replace_all_from(@frame.view_win.sci_get_current_pos, str, newstr)
        @frame.echo_puts(replace_summary(count))
        @frame.modeline(self)
      end
    end

    def query_replace(str = nil, newstr = nil)
      replace_string(str, newstr, true)
    end

    # Blocking query-replace loop: search for the next match, show it, and
    # wait for one confirmation key per match. Unlike ApplicationGui (whose
    # per-match prompt is a separate non-modal echo-area state), a key that
    # is not one of y/n/!/q/C-g simply ends the loop, the same as q/Enter,
    # since there is no separate turn to ignore it and wait for the next one.
    def query_replace_from(start_pos, search_text, replacement_text)
      view = @frame.view_win
      next_pos = start_pos
      count = 0
      message = nil
      with_undo_action do
        loop do
          view.sci_set_target_start(next_pos)
          view.sci_set_target_end(view.sci_get_length)
          break if view.sci_search_in_target(search_text.bytesize, search_text) == -1

          view.sci_set_sel(view.sci_get_target_start, view.sci_get_target_end)
          search_highlight_begin(search_text, :replace)
          @frame.modeline(self)
          @frame.view_win.refresh
          @frame.echo_set_prompt(query_replace_prompt(search_text, replacement_text))

          _ret, key = @frame.waitkey(@frame.echo_win)
          key_str = @frame.strfkey(key)
          case key_str
          when 'y', ' '
            view.sci_replace_target(replacement_text.bytesize, replacement_text)
            count += 1
            next_pos = view.sci_get_target_end
          when 'n', 'DEL'
            next_pos = view.sci_get_target_end
          when '!'
            view.sci_replace_target(replacement_text.bytesize, replacement_text)
            count += 1
            count += replace_all_from(view.sci_get_target_end, search_text, replacement_text)
            break
          when 'C-g'
            message = 'Quit'
            break
          else # 'q', 'Enter', or anything unrecognized
            break
          end
        end
      end
      search_highlight_end
      @frame.echo_puts(message || replace_summary(count))
      @frame.modeline(self)
    end
  end
end
