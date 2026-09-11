module Mrbmacs
  # Application class for terminal
  class ApplicationTerminal < Application
    def copy_region
      super
      str = @clipboard_text || ''
      if Scintilla::PLATFORM == :CURSES_WIN32
        IO.popen('clip.exe', 'r+') { |f| f << str }
      else
        # try pbcopy
        `type pbcopy 2>/dev/null`
        if $?.exitstatus == 0
          IO.popen('pbcopy', 'w') { |f| f << str }
        end
      end
    end

    def yank
      if @clipboard_text.nil? || @clipboard_text == ''
        `type pbpaste 2>/dev/null`
        if $?.exitstatus == 0
          @clipboard_text = `pbpaste`
        end
      end
      unless @clipboard_text.nil? || @clipboard_text == ''
        @frame.view_win.sci_copytext(@clipboard_text.bytesize, @clipboard_text)
      end
      @frame.view_win.sci_paste
    end
  end
end
