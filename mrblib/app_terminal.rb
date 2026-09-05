module Mrbmacs
  # Application class for terminal
  class ApplicationTerminal < Application
    def copy_region
      super
      str = @frame.view_win.get_clipboard
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
      if @frame.view_win.get_clipboard == ''
        `type pbpaste 2>/dev/null`
        if $?.exitstatus == 0
          clipboard_text = `pbpaste`
          @frame.view_win.sci_copytext(clipboard_text.bytesize, clipboard_text)
        end
      end
      @frame.view_win.sci_paste
    end
  end
end
