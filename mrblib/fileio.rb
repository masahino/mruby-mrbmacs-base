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
      return if reject_directory_for_find_file(filename)

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
      return if reject_directory_for_find_file(filename)

      current = @current_buffer.filename.to_s
      if File.exist?(filename) &&
         (current.empty? || File.expand_path(filename) != File.expand_path(current))
        return unless @frame.y_or_n("File `#{filename}' exists; overwrite? (y or n) ")
      end

      @current_buffer.update_filename(filename)
      save_buffer
      apply_theme_to_mode(@current_buffer.mode, @frame.edit_win, @theme)
      @frame.set_buffer_name(@current_buffer.name)
    end
  end

  # Application
  class Application
    def reject_directory_for_find_file(filename)
      return false unless File.directory?(filename)

      message 'Cannot open a directory'
      true
    end

    # Expand a leading ~ / ~/ in a path the user typed into a file prompt.
    # ~user is left alone.
    def expand_input_path(path)
      return path unless path.start_with?('~')
      return Mrbmacs.homedir if path == '~'
      return Mrbmacs.homedir + path[1..-1] if path.start_with?('~/')

      path
    end

    # Completion candidates for an in-progress path typed into echo_gets.
    # With a block, it is called with (absolute_entry, basename) to keep an
    # entry. Returns [autocomplete_list, length_to_replace] for echo_gets.
    #
    #   "." and ".." are never offered; dotfiles are hidden until the user
    #   starts typing one; matching is case-insensitive; an unreadable or
    #   missing directory yields no candidates instead of raising out of the
    #   frontend's modal input loop.
    def path_completions(input_text)
      path = expand_input_path(input_text)
      if path.end_with?('/')
        dir = path
        stub = ''
      else
        dir = File.dirname(path)
        stub = File.basename(path)
      end

      entries =
        begin
          Dir.entries(dir)
        rescue StandardError
          []
        end

      matches = entries.select do |name|
        next false if name == '.' || name == '..'
        next false if name.start_with?('.') && !stub.start_with?('.')
        next false unless stub.empty? || name.downcase.start_with?(stub.downcase)

        block_given? ? yield(File.join(dir, name), name) : true
      end

      matches.map! do |name|
        File.directory?(File.join(dir, name)) ? "#{name}/" : name
      end
      [matches.sort.join(@frame.echo_win.sci_autoc_get_separator.chr), stub.length]
    end

    def read_dir_name(prompt, default_directory = nil)
      default_directory ||= @current_buffer.directory
      prefix_text = default_directory.dup
      prefix_text += '/' unless prefix_text.end_with?('/')
      dirname = @frame.echo_gets(prompt, prefix_text) do |input_text|
        path_completions(input_text) { |full, _name| File.directory?(full) }
      end
      @frame.modeline_refresh(self)
      dirname.nil? ? nil : expand_input_path(dirname)
    end

    def read_file_name(prompt, directory, default_name = nil)
      prefix_text = "#{directory}/"
      prefix_text += default_name unless default_name.nil?
      filename = @frame.echo_gets(prompt, prefix_text) do |input_text|
        path_completions(input_text)
      end
      @frame.modeline_refresh(self)
      filename.nil? ? nil : expand_input_path(filename)
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
