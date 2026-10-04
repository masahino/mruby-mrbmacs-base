module Mrbmacs
  # Git working tree status results.
  class VCStatusMode < Mode
    attr_accessor :root_directory, :paths

    def initialize
      super
      @name = 'vc-status'
      @root_directory = nil
      @paths = []
      @keymap['Enter'] = 'vc_status_open_file'
    end
  end

  class Application
    def vc_status_open_file
      mode = @current_buffer.mode
      return unless mode.is_a?(VCStatusMode)

      line = @frame.view_win.sci_line_from_position(@frame.view_win.sci_get_current_pos)
      path = mode.paths[line]
      return if path.nil?

      file = File.expand_path(path, mode.root_directory)
      split_window_vertically if @frame.edit_win_list.size == 1
      other_window
      find_file(file)
    end
  end
end
