module Mrbmacs
  # Command
  module Command
    describe_command :preview_theme, 'Display a preview of the current theme styles.'

    def preview_theme
      buffer_name = '*preview_theme*'
      result_buffer = Mrbmacs.get_buffer_from_name(@buffer_list, buffer_name)
      result_buffer = create_new_buffer(buffer_name) if result_buffer.nil?
      switch_to_buffer(buffer_name)
      result_buffer.docpointer = @frame.view_win.sci_get_docpointer
      @frame.view_win.sci_clear_all
      style_number = 0
      @current_buffer.mode.preview_sections(@theme).each do |title, entries|
        add_preview_text("\n#{title}\n")
        add_preview_text("#{format('%-35s', 'name')}  fore   back  italic  bold\n")
        add_preview_text("#{'=' * 63}\n")
        entries.each do |name, style|
          pos = @frame.view_win.sci_get_length
          text = preview_style_line(name, style)
          add_preview_text(text)
          @frame.view_win.sci_start_styling(pos, 0)
          @frame.view_win.sci_set_styling(text.bytesize, style_number)
          style_number += 1
        end
      end
    end

    private

    def preview_style_line(name, style)
      "#{format('%-35s', name.to_s)} #{format_preview_color(style.foreground)} " \
        "#{format_preview_color(style.background)} #{format('%5s', style.italic.to_s)}  " \
        "#{format('%5s', style.bold.to_s)}\n"
    end

    def format_preview_color(color)
      color.nil? ? '      ' : format('%06X', color)
    end

    def add_preview_text(text)
      @frame.view_win.sci_add_text(text.bytesize, text)
    end
  end
end
