module Mrbmacs
  # Buffer class
  class Buffer
    attr_accessor :filename, :directory, :basename,
                  :docpointer, :name, :encoding, :mode, :pos,
                  :vcinfo, :additional_info

    def initialize(filename = nil)
      @vcinfo = nil
      if filename.nil?
        @filename = ''
        @basename = ''
        @name = ''
        @directory = Dir.getwd
        @mode = Mrbmacs::Mode.instance
      elsif filename.start_with?('*') && filename.end_with?('*')
        @filename = ''
        @basename = ''
        @name = filename
        @directory = Dir.getwd
        @mode = Mrbmacs::ModeManager.set_mode_by_filename(filename)
      else
        update_filename(filename)
      end
      @encoding = 'utf-8'
      @docpointer = nil
      @pos = 0
      @additional_info = ''
    end

    def update_filename(filename)
      @filename = File.expand_path(filename)
      @name = File.basename(@filename)
      @basename = File.basename(@filename)
      @directory = File.dirname(@filename)
      @mode = Mrbmacs::ModeManager.set_mode_by_filename(filename)
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

  # Command
  module Command
    describe_command :revert_buffer, 'Reload the current buffer from its file.'

    def revert_buffer
      @frame.view_win.sci_set_read_only(0) if @current_buffer.name == '*Messages*'
      @frame.view_win.sci_clear_all
      insert_file(@current_buffer.filename)
      if @current_buffer.name == '*Messages*'
        @frame.view_win.sci_set_read_only(1)
        @frame.view_win.sci_document_end
        @frame.view_win.sci_set_savepoint
      end
    end

    describe_command :kill_buffer, 'Kill a buffer.'

    def kill_buffer(buffername = nil)
      return if @buffer_list.size <= 1

      if buffername.nil?
        echo_text = "kill-buffer (default #{@current_buffer.name}): "
        buffername = @frame.echo_gets(echo_text, '') do |input_text|
          buffer_list = @buffer_list.collect { |b| b.name }.select { |b| b[0, input_text.length] == input_text }
          [buffer_list.join(@frame.echo_win.sci_autoc_get_separator.chr), input_text.length]
        end
      end
      buffername = @current_buffer.name if buffername == ''
      # if buffer is modified
      if buffername =~ /^\*.*\*$/ # special buffer
        @logger.info "can't delete special buffer"
        return
      end
      target_buffer = Mrbmacs.get_buffer_from_name(@buffer_list, buffername)
      if target_buffer.nil?
        message 'no match'
        return
      end
      target_wins = @frame.edit_win_list.select { |w| w.buffer == target_buffer }

      if !target_wins.empty? && target_wins.first.sci.sci_get_modify != 0
        ret = @frame.y_or_n("Buffer #{buffername} modified; kill anyway? (y or n) ")
        return if ret == false
      end

      new_buffer = (@buffer_list - [target_buffer]).last

      target_wins.each do |win|
        win.sci.sci_set_docpointer(new_buffer.docpointer)
        win.buffer = new_buffer
        apply_theme_to_mode(new_buffer.mode, win, @theme)
        win.sci.sci_goto_pos(new_buffer.pos)
      end

      @buffer_list.delete(target_buffer)

      @current_buffer = @frame.edit_win.buffer
      @frame.sync_tab(@current_buffer.name)
      @frame.modeline(self)
      after_kill_buffer(self, target_buffer)
    end

  end

  # Application
  class Application
    def update_buffer_mode(buffer)
      apply_theme_to_mode(buffer.mode, @frame.edit_win, @theme)
    end

    def update_buffer_window(new_buffer)
      @current_buffer.pos = @frame.view_win.sci_get_current_pos
      @frame.view_win.sci_add_refdocument(@current_buffer.docpointer)
      @frame.view_win.sci_set_docpointer(new_buffer.docpointer)
      @frame.edit_win.buffer = new_buffer
      update_buffer_mode(new_buffer)
      @frame.view_win.sci_goto_pos(new_buffer.pos)
      @current_buffer = new_buffer
      @frame.sync_tab(new_buffer.name)
      recenter
      @frame.modeline(self)
    end

    def switch_to_buffer(buffername = nil)
      if buffername.nil?
        buffername = @frame.select_buffer(@buffer_list[-2].name, @buffer_list.collect { |b| b.name })
      end
      return if buffername.nil?

      buffername = @buffer_list[-2].name if buffername == ''
      return if buffername == @current_buffer.name

      new_buffer = Mrbmacs.get_buffer_from_name(@buffer_list, buffername)
      unless new_buffer.nil?
        @buffer_list.push(@buffer_list.delete(new_buffer))
        update_buffer_window(new_buffer)
      end
    end

    def add_new_buffer(new_buffer)
      @buffer_list.push(new_buffer)
      return if new_buffer.basename == ''

      duplicates = @buffer_list.select { |b| b.basename == new_buffer.basename }
      return unless duplicates.size > 1

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
        next if b.basename != new_buffer.basename

        tmp_str = b.directory.gsub(/^\//, '')
        if tmp_str.count('/') < n
          b.name = "#{b.basename}<#{tmp_str}>"
        else
          b.name = "#{b.basename}<#{tmp_str.split('/')[-n, n].join('/')}>"
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
      update_buffer_mode(new_buffer)
      @frame.apply_theme(@theme)
      @frame.set_buffer_name(buffer_name)
      new_buffer
    end
  end
end
