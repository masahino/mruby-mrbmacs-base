module Mrbmacs
  # messages
  class Application
    def refresh_messages_buffer
      return unless @current_buffer.name == '*Messages*'
      return if @current_buffer.filename.nil? || @current_buffer.filename == ''

      revert_buffer
    end

    def create_messages_buffer(logfile)
      find_file(logfile)
      @current_buffer.name = '*Messages*'
      @frame.set_buffer_name(@current_buffer.name)
      @current_buffer.directory = Dir.getwd
      @frame.view_win.sci_set_readonly(1)
      @frame.view_win.sci_document_end
      @frame.view_win.sci_set_change_history(0)
      add_sci_event(Scintilla::SCN_FOCUSIN) do |app, _scn|
        app.revert_buffer if app.current_buffer.name == '*Messages*'
      end
      switch_to_buffer '*scratch*'
    end
  end
end
