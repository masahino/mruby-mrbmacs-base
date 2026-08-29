# Mrbmacs
module Mrbmacs
  def self.dir_glob(input_text)
    file_list = []
    len = 0
    if input_text[-1] == File::SEPARATOR
      file_list = (Dir.entries(input_text) - ['.', '..']).sort
    else
      dir = File.dirname(input_text)
      fname = File.basename(input_text)
      Dir.foreach(dir) do |item|
        file_list.push(item) if item =~ /^#{fname}/
      end
      len = fname.length
    end
    [file_list, len]
  end

  # Command
  module Command
    def insert_file(file_path = nil)
      file_path = read_file_name('insert file: ', @current_buffer.directory) if file_path.nil?
      return if file_path.nil?

      if File.exist?(file_path) == true && FileTest.file?(file_path) == true
        encoding = identify_file_encoding(file_path)
        insert_text_from_file(file_path, encoding)
      else
        message('no match')
      end
    end

    def find_file(filename = nil)
      filename = read_file_name('find file: ', @current_buffer.directory) if filename.nil?
      return if filename.nil?

      if Mrbmacs.get_buffer_from_path(@buffer_list, filename).nil?
        @current_buffer.pos = @frame.view_win.sci_get_current_pos
        new_buffer = Buffer.new(filename)
        unless @current_buffer.docpointer.nil?
          @frame.view_win.sci_add_refdocument(@current_buffer.docpointer)
        end
        @frame.view_win.sci_set_docpointer(nil)
        new_buffer.docpointer = @frame.view_win.sci_get_docpointer
        add_new_buffer(new_buffer)
        @current_buffer = new_buffer
        add_buffer_to_frame(@current_buffer)
        open_file(filename)
        apply_theme_to_mode(@current_buffer.mode, @frame.edit_win, @theme)
        @frame.set_buffer_name(@current_buffer.name)
        @frame.edit_win.buffer = @current_buffer
        @frame.modeline(self)
        if @config.use_builtin_syntax_check == true
          error = @current_buffer.mode.syntax_check(@frame.view_win)
          @frame.show_annotation(error[0], error[1], error[2]) if error.size > 0
        end
      else
        switch_to_buffer(Mrbmacs.get_buffer_from_path(@buffer_list, filename).name)
      end
      vc_refresh_gutter
      after_find_file(self, filename)
    end

    def save_buffer
      all_text = @frame.view_win.sci_get_text(@frame.view_win.sci_get_length + 1)
      if @current_buffer.encoding != 'utf-8'
        all_text = Iconv.conv(@current_buffer.encoding, 'utf-8', all_text)
      end
      #    $stderr.print all_text
      #      File.open(app.filename, "w") do |f|
      File.open(@current_buffer.filename, 'w') do |f|
        f.write all_text
      end
      @frame.view_win.sci_set_save_point

      if @config.use_builtin_syntax_check == true
        @frame.view_win.sci_annotation_clearall
        error = @current_buffer.mode.syntax_check(@frame.view_win)
        @frame.show_annotation(error[0], error[1], error[2]) if error.size > 0
      end
      vc_refresh_gutter
      after_save_buffer(self, @current_buffer.filename)
    end

    def write_file(filename = nil)
      if filename.nil?
        filename = read_save_file_name('write file: ', @current_buffer.directory, @current_buffer.basename)
      end
      return if filename.nil?

      @current_buffer.update_filename(filename)
      save_buffer
      apply_theme_to_mode(@current_buffer.mode, @frame.edit_win, @theme)
      @frame.set_buffer_name(@current_buffer.name)
    end
  end

  # Application
  class Application
    def read_dir_name(prompt, default_directory = nil)
      prefix_text = default_directory
      prefix_text += '/' if prefix_text[-1] != '/'
      dirname = @frame.echo_gets(prompt, prefix_text) do |input_text|
        dir_list = []
        len = 0
        if input_text[-1] == '/'
          dir_list = Dir.entries(input_text).select do |item|
            File.directory?(File.join(input_text, item))
          end
        else
          dir = File.dirname(input_text)
          fname = File.basename(input_text)
          qfname = Regexp.quote(fname)
          Dir.foreach(dir) do |item|
            if File.directory?(File.join(dir, item)) && item =~ /^#{qfname}/
              dir_list.push(item)
            end
          end
          len = fname.length
        end
        [dir_list.sort.join(@frame.echo_win.sci_autoc_get_separator.chr), len]
      end
      @frame.modeline_refresh(self)
      dirname
    end

    def read_file_name(prompt, directory, default_name = nil)
      prefix_text = "#{directory}/"
      prefix_text += default_name unless default_name.nil?
      filename = @frame.echo_gets(prompt, prefix_text) do |input_text|
        file_list = []
        len = 0
        if input_text[-1] == '/'
          dir = input_text
          file_list = Dir.entries(input_text)
        else
          dir = File.dirname(input_text)
          fname = File.basename(input_text)
          Dir.foreach(dir) do |item|
            file_list.push(item) if item.start_with?(fname)
          end
          len = fname.length
        end
        file_list.map! do |file_name|
          if File.directory?(File.join(dir, file_name))
            "#{file_name}/"
          else
            file_name
          end
        end
        [file_list.sort.join(@frame.echo_win.sci_autoc_get_separator.chr), len]
      end
      @frame.modeline_refresh(self)
      filename
    end

    def read_save_file_name(prompt, directory, default_name = nil)
      read_file_name(prompt, directory, default_name)
    end

    def identify_file_encoding(filename)
      file_encoding = 'utf-8'
      text = File.open(filename).read(4096)
      @config.file_encodings.each do |from|
        tmp_text = ''
        begin
          tmp_text = Iconv.conv('utf-8', from, text)
        rescue StandardError
          next
        end
        file_encoding = from if tmp_text.size != text.size
        break
      end
      file_encoding
    end

    def insert_text_from_file(filename, from_encoding)
      pos = @frame.view_win.sci_get_current_pos
      content = File.read(filename, mode: 'rb')
      content = Iconv.conv('utf-8', from_encoding, content) if from_encoding != 'utf-8'
      @frame.view_win.sci_add_text(content.bytesize, content)
      @frame.view_win.sci_goto_pos(pos)
    end

    def identify_eolmode
      eolmode = @frame.view_win.sci_get_eolmode
      text = @frame.view_win.sci_get_text(4096)
      cr = text.count("\r")
      lf = text.count("\n")
      if text.include?("\r\n")
        eolmode = Scintilla::SC_EOL_CRLF
      elsif lf > cr
        eolmode = Scintilla::SC_EOL_LF
      elsif cr > 0
        eolmode = Scintilla::SC_EOL_CR
      end
      @frame.view_win.sci_set_eolmode(eolmode)
    end

    def open_file(filename)
      unless File.exist?(filename)
        message 'New file'
        return
      end

      view_win = @frame.view_win
      begin
        @current_buffer.encoding = identify_file_encoding(filename)

        mod_mask = view_win.sci_get_mod_event_mask
        view_win.sci_set_mod_event_mask(0)
        view_win.sci_set_codepage(Scintilla::SC_CP_UTF8)
        insert_text_from_file(filename, @current_buffer.encoding)
        identify_eolmode
        view_win.sci_set_savepoint
        view_win.sci_empty_undo_buffer
        view_win.sci_set_mod_event_mask(mod_mask)
        view_win.sci_set_change_history(Scintilla::SC_CHANGE_HISTORY_ENABLED |
          Scintilla::SC_CHANGE_HISTORY_MARKERS)
      rescue StandardError => e
        @logger.error e.to_s
        message 'error load file'
      end
    end
  end
end
