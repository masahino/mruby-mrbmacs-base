module Mrbmacs
  # Buffer class
  class Buffer
    attr_accessor :filename, :directory, :basename,
                  :docpointer, :name, :encoding, :mode, :pos,
                  :vcinfo, :additional_info

    def initialize(filename = nil)
      @vcinfo = nil
      if filename != nil
        if filename =~ /^\*.*\*$/ # special buffer
          @filename = ''
          @basename = ''
          @name = filename
          @directory = Dir.getwd
          @mode = Mrbmacs::Mode.set_mode_by_filename(filename)
        else
          set_filename(filename)
        end
      else
        @filename = ''
        @basename = ''
        @name = ''
        @directory = Dir.getwd
        @mode = Mrbmacs::Mode.instance
      end
      @encoding = 'utf-8'
      @docpointer = nil
      @pos = 0
      @additional_info = ''
    end

    def set_filename(filename)
      @filename = File.expand_path(filename)
      @name = File.basename(@filename)
      @basename = File.basename(@filename)
      @directory = File.dirname(@filename)
      @mode = Mrbmacs::Mode.set_mode_by_filename(filename)
      @vcinfo = VC.new(@directory)
    end
  end

  class << self
    def get_buffer_from_name(buffer_list, name)
      buffer_list.each do |b|
        return b if b.name == name
      end
      nil
    end

    def get_buffer_from_path(buffer_list, file_path)
      path = File.expand_path(file_path)
      buffer_list.each do |b|
        return b if b.filename == path
      end
      nil
    end
  end

  module Command
    def revert_buffer
      if @current_buffer.name == '*Messages*'
        @frame.view_win.sci_set_read_only(0)
      end
      @frame.view_win.sci_clear_all
      insert_file(@current_buffer.filename)
      if @current_buffer.name == '*Messages*'
        @frame.view_win.sci_set_read_only(1)
        @frame.view_win.sci_document_end
        @frame.view_win.sci_set_savepoint
      end
    end

    def kill_buffer(buffername = nil)
      return if @buffer_list.size <= 1

      if buffername.nil?
        echo_text = "kill-buffer (default #{@current_buffer.name}): "
        buffername = @frame.echo_gets(echo_text, '') do |input_text|
          buffer_list = @buffer_list.collect { |b| b.name }.select { |b| b[0, input_text.length] == input_text }
          [buffer_list.join(' '), input_text.length]
        end
      end
      if buffername == ''
        buffername = @current_buffer.name
      end
      # if buffer is modified
      if buffername =~ /^\*.*\*$/ # special buffer
        @logger.info "can't delete special buffer"
        return
      end
      if @frame.view_win.sci_get_modify != 0
        ret = @frame.y_or_n("Buffer #{buffername} modified; kill anyway? (y or n) ")
        return if ret == false
      end
      # delete buffer
      target_buffer = Mrbmacs.get_buffer_from_name(@buffer_list, buffername)
      @buffer_list.delete(target_buffer)
      switch_to_buffer(@buffer_list.last.name)
    end
  end

  # Application
  class Application
    include Command

    def set_buffer_mode(buffer)
      buffer.mode.set_lexer(@frame.view_win)
      buffer.mode.set_style(@frame.view_win, @theme)
    end

    def update_buffer_window(new_buffer)
      @current_buffer.pos = @frame.view_win.sci_get_current_pos
      @frame.view_win.sci_add_refdocument(@current_buffer.docpointer)
      @frame.view_win.sci_set_docpointer(new_buffer.docpointer)
      @frame.edit_win.buffer = new_buffer
      set_buffer_mode(new_buffer)
      @frame.view_win.sci_goto_pos(new_buffer.pos)
      @current_buffer = new_buffer
      @frame.sync_tab(new_buffer.name)
      @frame.modeline(self)
    end

    def switch_to_buffer(buffername = nil)
      # if @buffer_list.size <= 1
      #   return
      # end
      if buffername.nil?
        buffername = @frame.select_buffer(@buffer_list[-2].name, @buffer_list.collect { |b| b.name })
      end
      if buffername != nil
        if buffername == ''
          buffername = @buffer_list[-2].name
        end
        if buffername == @current_buffer.name
          return
        end

        new_buffer = Mrbmacs.get_buffer_from_name(@buffer_list, buffername)
        if new_buffer != nil
          @buffer_list.push(@buffer_list.delete(new_buffer))
          update_buffer_window(new_buffer)
        end
      end
    end


    def add_new_buffer(new_buffer)
      @buffer_list.push(new_buffer)
      return if new_buffer.basename == ''

      duplicates = @buffer_list.select { |b| b.basename == new_buffer.basename }
      if duplicates.size > 1
        n = 1
        loop do
          dirs = duplicates.map do |b|
            tmp_str = b.directory.gsub(/^\//, '')
            if tmp_str.count('/') < n
              tmp_str
            else
              tmp_str.split('/')[-n, n].join('/')
            end
          end
          break if dirs.uniq == dirs

          n += 1
        end
        @buffer_list.each do |b|
          if b.basename == new_buffer.basename
            tmp_str = b.directory.gsub(/^\//, '')
            if tmp_str.count('/') < n
              b.name = b.basename + '<' + tmp_str + '>'
            else
              b.name = b.basename + '<' + tmp_str.split('/')[-n, n].join('/') + '>'
            end
          end
        end
      end
    end

    def add_buffer_to_frame(buffer)
      raise NotImplementedError
    end


    def create_new_buffer(buffer_name)
      new_buffer = Mrbmacs::Buffer.new(buffer_name)
      add_new_buffer(new_buffer)
      add_buffer_to_frame(new_buffer)
      set_buffer_mode(new_buffer)
      @frame.set_theme(@theme)
      @frame.set_buffer_name(buffer_name)
      new_buffer
    end
  end
end
