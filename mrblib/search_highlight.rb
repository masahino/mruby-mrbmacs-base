module Mrbmacs
  # Scintilla indicator used to paint every visible match during incremental
  # search. INDIC_CONTAINER (8) is not used anywhere else in mrbmacs.
  SEARCH_INDICATOR = 8
  # Scintilla INDIC_STRAIGHTBOX: a translucent box with a sharp outline that
  # sits behind the text without hiding it.
  SEARCH_INDICATOR_STYLE = 8

  # Passive "highlight all matches" for incremental search.
  #
  # Scintilla has no built-in facility for this, so matches are painted with an
  # indicator one range at a time. To keep the cost bounded on large files only
  # the *visible* range is painted; it is repainted from the SCN_UPDATEUI
  # handler while a search is active, so scrolling keeps the highlight in sync.
  class Application
    def search_highlight_active?
      !@search_highlight_text.nil?
    end

    # Start (or update) highlighting of `text`. Passing nil / "" clears it.
    def search_highlight_begin(text)
      @search_highlight_text = text.nil? || text.empty? ? nil : text
      refresh_search_highlight
    end

    def search_highlight_end
      return unless search_highlight_active?

      @search_highlight_text = nil
      view = @frame.view_win
      view.sci_set_indicator_current(SEARCH_INDICATOR)
      view.sci_indicator_clear_range(0, view.sci_get_length)
    end

    # Repaint indicators for matches inside the visible range. Safe to call
    # repeatedly; a no-op when no search is active.
    def refresh_search_highlight
      view = @frame.view_win
      length = view.sci_get_length
      view.sci_set_indicator_current(SEARCH_INDICATOR)
      view.sci_indicator_clear_range(0, length)
      text = @search_highlight_text
      return if text.nil?

      first_line = view.sci_get_first_visible_line
      last_line = first_line + view.sci_lines_on_screen + 1
      range_start = view.sci_position_from_line(first_line)
      range_end = view.sci_get_line_end_position(last_line)
      range_end = length if range_end < 0 || range_end > length

      saved_start = view.sci_get_target_start
      saved_end = view.sci_get_target_end
      pos = range_start
      while pos < range_end
        view.sci_set_target_start(pos)
        view.sci_set_target_end(range_end)
        break if view.sci_search_in_target(text.bytesize, text) == -1

        match_start = view.sci_get_target_start
        match_end = view.sci_get_target_end
        break if match_end <= match_start

        view.sci_indicator_fill_range(match_start, match_end - match_start)
        pos = match_end
      end
      view.sci_set_target_start(saved_start)
      view.sci_set_target_end(saved_end)

      # The current match is already shown by the selection; keep the
      # lazy-highlight indicator off it so the two do not stack (most visible
      # in the terminal, where the selection is reverse video).
      sel_start = view.sci_get_selection_start
      sel_end = view.sci_get_selection_end
      view.sci_indicator_clear_range(sel_start, sel_end - sel_start) if sel_end > sel_start
    end
  end
end
