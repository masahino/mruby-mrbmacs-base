module Mrbmacs
  # Project search results
  class ProjectsearchMode < GrepMode
    attr_accessor :root_directory

    def initialize
      super
      @name = 'project-search'
      @keymap['Enter'] = 'project_search_open_file'
      @root_directory = nil
    end
  end

  class Application
    def project_search_open_file
      line_str = @frame.view_win.sci_get_curline[0]
      return unless line_str =~ /^(.+):(\d+):(.*)$/

      root_directory = @current_buffer.mode.root_directory
      file = File.expand_path(Regexp.last_match[1], root_directory)
      line = Regexp.last_match[2].to_i - 1
      split_window_vertically if @frame.edit_win_list.size == 1
      other_window
      find_file(file)
      pos = @frame.view_win.sci_position_from_line(line)
      @frame.view_win.sci_goto_pos(pos)
    end
  end
end
