module Mrbmacs
  # SciEvent class
  class SciEvent
    attr_accessor :priority, :proc

    def initialize(priority, proc)
      @priority = priority
      @proc = proc
    end
  end

  # methods
  class Application
    def init_default_sci_event
      if @config.use_builtin_completion
        add_sci_event(Scintilla::SCN_CHARADDED) do |_app, scn|
          builtin_completion(scn)
        end
      end

      add_sci_event(Scintilla::SCN_UPDATEUI) do |_app, scn|
        brace_highlight(scn)
        display_selection_range(scn)
        refresh_search_highlight if search_highlight_active?
      end

      add_sci_event(Scintilla::SCN_STYLENEEDED) do |app, scn|
        @current_buffer.mode.on_style_needed(app, scn)
      end
    end

    def call_sci_event(event)
      return if @sci_handler[event['code']].nil?

      begin
        @sci_handler[event['code']].each do |s|
          s.proc.call(self, event)
        end
      rescue StandardError => e
        @logger.error e.to_s
        @logger.error e.backtrace
        @frame.echo_puts e.to_s
      end
    end

    def brace_highlight(_scn)
      pos = @frame.view_win.sci_bracematch(get_current_pos, 0)
      if pos != -1
        @frame.view_win.sci_brace_highlight(pos, get_current_pos)
      else
        @frame.view_win.sci_brace_highlight(-1, -1)
      end
    end

    def display_selection_range(scn)
      if scn['updated'] & Scintilla::SC_UPDATE_SELECTION
        if @mark_pos != nil
          #          @frame.view_win.sci_set_anchor(@mark_pos)
        end
      end
    end
  end
end
