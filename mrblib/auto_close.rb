module Mrbmacs
  class Extension
  end

  # AutoCloseExtension
  class AutoCloseExtension < Extension
    BRACE_PAIRS = {
      '(' => ')',
      '{' => '}',
      '[' => ']'
    }.freeze
    def self.extension_id
      :auto_close
    end

    def self.on_char_added(app, ch_code)
      ch = ch_code.chr('UTF-8')
      pos = app.frame.view_win.sci_get_current_pos
      nxt = app.frame.view_win.sci_get_char_at(pos)
      if BRACE_PAIRS.keys.include?(ch)
        if [0, 9, 10, 13, 32].include?(nxt)
          app.frame.view_win.sci_insert_text(app.frame.view_win.sci_get_current_pos, BRACE_PAIRS[ch])
        end
      end
    end

    def self.register_auto_close(appl)
      appl.add_sci_event(Scintilla::SCN_CHARADDED, 10) do |app, scn|
        next unless app.current_buffer.mode.use_builtin_formatting

        count = app.frame.sci_notifications.count { |hash| hash['code'] == Scintilla::SCN_CHARADDED }
        next if count.positive?

        on_char_added(app, scn['ch'])
      end
    end
  end
end
