module Mrbmacs
  # Modeline
  class Modeline
    attr_accessor :format

    def initialize
      @format = '(%<encoding>s-%<eol>s):%<modified>s %<buffername>s %<pos>s    (%<vcinfo>s)    [%<project>s]    [%<modename>s]    [%<additional_info>s]'
    end
  end

  # Application
  class Application
    def modeline_str
      format(
        @modeline.format,
        encoding: modeline_encoding,
        eol: modeline_eol,
        modified: modeline_modified,
        buffername: modeline_buffername,
        pos: modeline_pos,
        vcinfo: modeline_vcinfo,
        project: modeline_project,
        modename: modeline_modename,
        additional_info: modeline_additional_info
      )
    end

    def modeline_format(format)
      @modeline.format = format
    end

    def modeline_encoding
      @current_buffer.encoding
    end

    def modeline_eol
      @frame.edit_win.newline
    end

    def modeline_modified
      modified = @frame.view_win.sci_get_modify != 0
      readonly = @frame.view_win.sci_get_readonly

      if readonly
        modified ? '%*' : '%%'
      else
        modified ? '**' : '--'
      end
    end

    def modeline_buffername
      @current_buffer.name
    end

    def modeline_pos
      "(#{current_col + 1},#{current_line + 1})"
    end

    def modeline_modename
      @current_buffer.mode.name
    end

    def modeline_project
      return '' if @project.nil?

      "project:#{@project.name}"
    end

    def modeline_additional_info
      @current_buffer.additional_info
    end

    def modeline_vcinfo
      @current_buffer.vcinfo.to_s
    end
  end
end
