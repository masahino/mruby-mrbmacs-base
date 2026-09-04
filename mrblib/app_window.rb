module Mrbmacs
  # Command
  module Command
    describe_command :other_window, 'Select the next editor window.'

    def other_window
      return if @frame.edit_win_list.size == 0

      index = @frame.edit_win_list.index(@frame.edit_win) + 1
      index = 0 if index >= @frame.edit_win_list.size
      @frame.switch_window(@frame.edit_win_list[index])
      # @frame.switch_window(@frame.edit_win_list.rotate!().first)
      @current_buffer = @frame.edit_win.buffer
      # set_buffer_mode(@current_buffer)
    end

    describe_command :delete_window, 'Delete the current editor window.'

    def delete_window
      @frame.delete_window(@frame.edit_win)
      @current_buffer = @frame.edit_win.buffer
    end

    describe_command :delete_other_window, 'Delete all editor windows except the current one.'

    def delete_other_window
      @frame.delete_other_window
    end

    describe_command :split_window_vertically, 'Split the current window into upper and lower windows.'

    def split_window_vertically
      split_window(false)
    end

    describe_command :split_window_horizontally, 'Split the current window into left and right windows.'

    def split_window_horizontally
      split_window(true)
    end

    describe_command :enlarge_window, 'Enlarge the current window vertically.'

    def enlarge_window(line = 1)
      return if @frame.edit_win_list.size == 1

      @frame.enlarge_window(@frame.edit_win, line)
    end

    describe_command :enlarge_window_horizontally, 'Enlarge the current window horizontally.'

    def enlarge_window_horizontally(line = 1)
      return if @frame.edit_win_list.size == 1

      @frame.enlarge_window_horizontally(@frame.edit_win, line)
    end

  end

  # Application
  class Application
    def split_window(horizon)
      active_win = @frame.edit_win
      active_win.refresh
      if horizon == true
        x = ((active_win.x2 + active_win.x1) / 2).to_i + 1
        y = active_win.y1
        new_width = active_win.x2 - x + 1
        new_height = active_win.height
        if new_width < 10
          @frame.echo_puts('too small for splitting')
          return
        end
        active_win.x2 = x - 1
      else
        y = ((active_win.y2 + active_win.y1) / 2).to_i + 1
        x = active_win.x1
        new_width = active_win.width
        new_height = active_win.y2 - y + 1
        if new_height < 3
          @frame.echo_puts('too small for splitting')
          return
        end
        active_win.y2 = y - 1
      end

      active_win.compute_area
      active_win.refresh
      new_win = @frame.new_editwin(@current_buffer, x, y, new_width, new_height)
      apply_keymap(new_win.sci, @keymap)
      new_win.apply_theme(@theme)
      apply_theme_to_mode(@current_buffer.mode, new_win, @theme)
      @frame.edit_win_list.push(new_win)
      @frame.edit_win_list.each do |win|
        win.refresh
      end
      @frame.modeline(self, new_win)
      @frame.modeline_refresh(self)
      new_win.focus_out
    end

    def apply_theme_to_mode(mode, edit_win, theme)
      mode.apply_lexer(edit_win.sci)
      mode.apply_theme(edit_win.sci, theme, @config.styles)
      edit_win.apply_mode_settings(mode)
    end
  end
end
