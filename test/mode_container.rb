module Mrbmacs
  module TestSupport
    class ContainerStyleView
      attr_reader :styles

      def initialize(line)
        @line = line
        @styles = []
      end

      def sci_get_end_styled
        0
      end

      def sci_line_from_position(_position)
        0
      end

      def sci_position_from_line(_line)
        0
      end

      def sci_line_length(_line)
        @line.length
      end

      def sci_get_line(_line)
        @line
      end

      def sci_start_styling(position, mask)
        @styles << [:start, position, mask]
      end

      def sci_set_styling(length, style)
        @styles << [length, style]
      end
    end

    class ContainerStyleFrame
      attr_reader :view_win

      def initialize(view)
        @view_win = view
      end
    end

    class ContainerStyleBuffer
      attr_reader :mode

      def initialize(mode)
        @mode = mode
      end
    end

    class ContainerStyleApp
      attr_reader :frame, :current_buffer

      def initialize(view, mode)
        @frame = ContainerStyleFrame.new(view)
        @current_buffer = ContainerStyleBuffer.new(mode)
      end
    end
  end
end

assert('CompilationMode container lexer styles file position and error') do
  line = '/tmp/main.rb:7:3: syntax error'
  view = Mrbmacs::TestSupport::ContainerStyleView.new(line)
  mode = Mrbmacs::CompilationMode.new
  app = Mrbmacs::TestSupport::ContainerStyleApp.new(view, mode)

  mode.on_style_needed(app, { 'position' => line.length })

  assert_equal [
    [:start, 0, 0],
    [12, Mrbmacs::COMPILATION_STYLE_FILE],
    [1, Mrbmacs::COMPILATION_STYLE_DEFAULT],
    [1, Mrbmacs::COMPILATION_STYLE_NUMBER],
    [1, Mrbmacs::COMPILATION_STYLE_DEFAULT],
    [1, Mrbmacs::COMPILATION_STYLE_NUMBER],
    [2, Mrbmacs::COMPILATION_STYLE_DEFAULT],
    [12, Mrbmacs::COMPILATION_STYLE_ERROR]
  ], view.styles
end

assert('GrepMode container lexer styles file line and matched pattern') do
  line = '/tmp/main.rb:7:hello mrbmacs world'
  view = Mrbmacs::TestSupport::ContainerStyleView.new(line)
  mode = Mrbmacs::GrepMode.new
  mode.instance_variable_set(:@pattern, 'mrbmacs')
  app = Mrbmacs::TestSupport::ContainerStyleApp.new(view, mode)

  mode.on_style_needed(app, { 'position' => line.length })

  assert_equal [
    [:start, 0, 0],
    [12, Mrbmacs::GREP_STYLE_FILE],
    [1, Mrbmacs::GREP_STYLE_DEFAULT],
    [1, Mrbmacs::GREP_STYLE_NUMBER],
    [1, Mrbmacs::GREP_STYLE_DEFAULT],
    [6, Mrbmacs::GREP_STYLE_DEFAULT],
    [7, Mrbmacs::GREP_STYLE_PATTERN],
    [6, Mrbmacs::GREP_STYLE_DEFAULT]
  ], view.styles
end
