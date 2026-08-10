module Mrbmacs
  # Base class of Frame
  class FrameBase
    attr_accessor :view_win, :echo_win, :sci_notifications, :edit_win_list, :edit_win

    def init_keysyms
      @keysyms = [0,
                  Scintilla::SCK_BACK,
                  Scintilla::SCK_TAB,
                  Scintilla::SCK_RETURN,
                  Scintilla::SCK_ESCAPE,
                  0,
                  Scintilla::SCK_BACK,
                  Scintilla::SCK_UP,
                  Scintilla::SCK_DOWN,
                  Scintilla::SCK_LEFT,
                  Scintilla::SCK_RIGHT,
                  0, 0,
                  Scintilla::SCK_INSERT,
                  Scintilla::SCK_DELETE,
                  0,
                  Scintilla::SCK_PRIOR,
                  Scintilla::SCK_NEXT,
                  Scintilla::SCK_HOME,
                  Scintilla::SCK_END]
    end

    def apply_theme(theme)
      @theme = theme
      @edit_win_list.each do |w|
        w.apply_theme(theme)
      end
    end

    def get_mode_str(app)
      app.modeline_str
    end

    # (ENCODING-EOL):---____FILENAME____________(X,Y)_____[MODE____][ADDITIONAL-INFO__]
    def get_mode_str_builtin(app)
      newline = @edit_win.newline
      mode_text = " (#{app.current_buffer.encoding}-#{newline}):"
      if @view_win.sci_get_modify != 0
        if @view_win.sci_get_readonly != 0
          mode_text += '%*'
        else
          mode_text += '**'
        end
      elsif @view_win.sci_get_readonly != 0
        mode_text += '%%'
      else
        mode_text += '--'
      end
      mode_text += format('    %-20s', app.current_buffer.name)
      x = @view_win.sci_get_column(@view_win.sci_get_current_pos) + 1
      y = @view_win.sci_line_from_position(@view_win.sci_get_current_pos) + 1
      mode_text += format('%-10s', "(#{x},#{y})")
      mode_text += format('%-10s', "[#{app.current_buffer.mode.name}]")
      mode_text += format('%-20s', "[#{app.current_buffer.additional_info}]")
      mode_text
    end

    def set_buffer_name(name)
    end

    def show_annotation(line, _column, message, style = 254)
      view_win.sci_annotation_set_text(line - 1, message)
      view_win.sci_annotation_set_style(line - 1, style)
    end

    def sync_tab(buffername)
    end

    def edit_win_from_buffer(buffer_name)
      edit_win_list.each do |w|
        return w if w.buffer.name == buffer_name
      end
      nil
    end

    def get_edit_win_from_pos(line, col)
      @edit_win_list.each do |w|
        return w if line >= w.y1 && line <= w.y2 && col >= w.x1 && col <= w.x2
      end
      nil
    end

    def switch_window(new_win)
      @edit_win.focus_out
      @edit_win = new_win
      @view_win = new_win.sci
      @mode_win = new_win.mode_win
      new_win.focus_in
    end

    def delete_window(target_win)
      if @edit_win_list.size == 1
        echo_puts('Atempt to delete sole ordinary window')
        return
      end
      x1 = target_win.x1
      x2 = target_win.x2
      y1 = target_win.y1
      y2 = target_win.y2
      new_win = nil
      count = 0
      expand_wins = {}
      expand_wins[:left] = []
      expand_wins[:right] = []
      expand_wins[:top] = []
      expand_wins[:bottom] = []

      @edit_win_list.each do |e|
        next if e == target_win

        new_win = e

        if x1 == (e.x2 + 1) && y1 == e.y1 && y2 == e.y2
          # left border
          e.x2 = x2
          count += 1
          break
        elsif (x2 + 1) == e.x1 && y1 == e.y1 && y2 == e.y2
          # right border
          e.x1 = x1
          count += 1
          break
        elsif y1 == (e.y2 + 1) && x1 == e.x1 && x2 == e.x2
          #  top border
          e.y2 = y2
          count += 1
          break
        elsif (y2 + 1) == e.y1 && x1 == e.x1 && x2 == e.x2
          # bottom border
          e.y1 = y1
          count += 1
          break
        elsif x1 == (e.x2 + 1)
          expand_wins[:left].push e
        elsif (x2 + 1) == e.x1
          expand_wins[:right].push e
        elsif y1 == (e.y2 + 1)
          expand_wins[:top].push e
        elsif (y2 + 1) == e.y1
          expand_wins[:bottom].push e
        end
      end
      if count == 0
        if expand_wins[:left].size > 1
          count = expand_wins[:left].size
          expand_wins[:left].each do |w|
            w.x2 = x2
            w.compute_area
          end
          new_win = expand_wins[:left].first
        elsif expand_wins[:right].size > 1
          count = expand_wins[:right].size
          expand_wins[:right].each do |w|
            w.x1 = x1
            w.compute_area
          end
          new_win = expand_wins[:right].first
        elsif expand_wins[:top].size > 1
          count = expand_wins[:top].size
          expand_wins[:top].each do |w|
            w.y2 = y2
            w.compute_area
          end
          new_win = expand_wins[:top].first
        elsif expand_wins[:bottom].size > 1
          count = expand_wins[:bottom].size
          expand_wins[:bottom].each do |w|
            w.y1 = y1
            w.compute_area
          end
          new_win = expand_wins[:bottom].first
        end
      end
      if count > 0
        new_win.compute_area
        switch_window(new_win)
        target_win.sci.sci_add_refdocument(target_win.buffer.docpointer)
        target_win.delete
        @edit_win_list.delete(target_win)
        @edit_win_list.each do |w|
          w.refresh
        end
      else
        echo_puts "can't find any window"
      end
    end

    def enlarge_window(active_win, line)
      downward_shrink_win = []
      downward_enlarge_win = [active_win]
      upward_shrink_win = []
      upward_enlarge_win = [active_win]
      @edit_win_list.each do |win|
        next if win == active_win

        downward_shrink_win.push win if win.y1 == active_win.y2 + 1 && win.height - line > 10
        downward_enlarge_win.push win if win.y2 == active_win.y2
        upward_shrink_win.push win if win.y2 == active_win.y1 - 1 && win.height - line > 10
        upward_enlarge_win.push win if win.y1 == active_win.y1
      end
      if downward_shrink_win.size > 0
        downward_shrink_win.each do |win|
          win.y1 += line
          win.compute_area
        end
        downward_enlarge_win.each do |win|
          win.y2 += line
          win.compute_area
        end
      elsif upward_shrink_win.size > 0
        upward_shrink_win.each do |win|
          win.y2 -= line
          win.compute_area
        end
        upward_enlarge_win.each do |win|
          win.y1 -= line
          win.compute_area
        end
      end
      refresh_all
    end

    def enlarge_window_horizontally(active_win, col)
      right_shrink_win = []
      right_enlarge_win = [active_win]
      left_shrink_win = []
      left_enlarge_win = [active_win]
      @edit_win_list.each do |win|
        next if win == active_win

        right_shrink_win.push win if win.x1 == active_win.x2 + 1 && win.width - col > 10
        right_enlarge_win.push win if win.x2 == active_win.x2
        left_shrink_win.push win if win.x2 == active_win.x1 - 1 && win.width - col > 10
        left_enlarge_win.push win if win.x1 == active_win.x1
      end
      if right_shrink_win.size > 0
        right_shrink_win.each do |win|
          win.x1 += col
          win.compute_area
        end
        right_enlarge_win.each do |win|
          win.x2 += col
          win.compute_area
        end
      elsif left_shrink_win.size > 0
        left_shrink_win.each do |win|
          win.x2 -= col
          win.compute_area
        end
        left_enlarge_win.each do |win|
          win.x1 -= col
          win.compute_area
        end
      end
      refresh_all
    end

    def refresh_all
      @edit_win_list.each do |win|
        win.refresh
      end
    end

    def modeline_refresh(_app)
    end

    def exit
      raise NotImplementedError
    end
  end

  class Frame < FrameBase
  end
end
