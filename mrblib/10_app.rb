module Mrbmacs
  # Application
  class Application
    attr_accessor :frame, :current_buffer, :buffer_list, :theme,
                  :sci_handler, :ext, :config, :io_handler
    attr_reader :project

    def initialize(argv = [])
      opts, argv = parse_args(argv)
      init_instance_variables
      @logger = init_logfile
      init_buffer
      init_frame
      init_keymap

      @project = Project.new(@current_buffer.directory)
      load_init_file if opts[:q] == false
      # after load initialize file
      init_theme
      register_extensions
      init_default_sci_event
      create_messages_buffer(@logfile)

      find_file(argv[0]) if argv.size > 0
      load_file(opts[:load]) unless opts[:load].nil?
      @command_list = Mrbmacs::Command.instance_methods.map(&:to_s).sort
    end

    def print_usage
      puts "Usage: #{$0} [OPTION-OR-FILENAME]..."
      puts '-q                 do not load ~/.mrbmacs'
      puts '-l, --load FILE    load ruby file'
      puts '-d, --debug        set debugging flags (set $DEBUG to true)'
      puts '-h, --help         Prints this help'
      puts '-v, --veresion     show version'
    end

    def parse_args(argv)
      parser = OptParser.new do |opts|
        opts.on(:q, :bool, false)
        opts.on(:load, :string)
        opts.on(:debug, :bool, false) { |debug| $DEBUG = debug }
        opts.on(:help, :bool, false) do |help|
          if help
            print_usage
            exit
          end
        end
        opts.on(:version, :bool, false) do |version|
          if version
            puts Version
            exit
          end
        end
      end
      begin
        parser.parse(argv)
      rescue StandardError => e
        puts e.message
        print_usage
        exit
      end
      [parser.opts, parser.tail]
    end

    def load_init_file
      homedir = Mrbmacs.homedir
      init_filename = "#{homedir}/.mrbmacsrc"
      @logger.debug 'load initfile'
      load_file(init_filename)
    end

    def init_logfile
      tmpdir = ENV['TMPDIR'] || ENV['TMP'] || ENV['TEMP'] || ENV['USERPROFILE'] || '/tmp'
      @logfile = "#{tmpdir}/mrbmacs-#{$$}.log"
      severity = $DEBUG ? Logger::Severity::DEBUG : Logger::Severity::INFO
      logger = Logger.new(@logfile, level: severity)
      logger.info 'Logging start'
      logger.info @logfile
      logger
    end

    def init_instance_variables
      @io_handler = {}
      @sci_handler = {}
      @command_handler = {}
      @ext = Extension.new
      @config = Config.new
      @theme = nil
      @modeline = Modeline.new
      @mark_pos = nil
      @recent_keys = []
      @readings = []
      @target_start_pos = nil
      @last_search_text = ''
    end

    def init_buffer
      @current_buffer = Buffer.new('*scratch*')
      @buffer_list = [@current_buffer]
    end

    def init_frame
      @frame = Mrbmacs::Frame.new(@current_buffer)
      @frame.set_buffer_name(@current_buffer.name)
      @current_buffer.docpointer = @frame.view_win.sci_get_docpointer
    end

    def init_theme
      @theme = @config.theme.new
      @frame.apply_theme(@theme)
      apply_theme_to_mode(@current_buffer.mode, @frame.edit_win, @theme)
    end

    def load_file(filename)
      File.open(File.expand_path(filename), 'r') do |f|
        str = f.read
        instance_eval(str, filename)
      end
    rescue StandardError => e
      @logger.error e
    end

    def add_recent_key(key)
      @recent_keys.push key
      @recent_keys.shift if @recent_keys.length > 100
    end

    def extend(command)
      if command.is_a?(Integer)
        @frame.view_win.send_message(command)
      else
        begin
          instance_eval("#{command.gsub('-', '_')}()", __FILE__, __LINE__)
        rescue StandardError => e
          @logger.error e.to_s
          @frame.echo_puts e.to_s
        end
      end
    end

    def doin
      key, command = doscan('')
      return if key.nil?

      @logger.debug command
      if command.nil?
        @frame.send_key(key)
      else
        extend(command)
      end
    end

    def run(file = nil)
      @logger.debug 'run'
      find_file(file) unless file.nil?
      editloop
    end
  end
end
