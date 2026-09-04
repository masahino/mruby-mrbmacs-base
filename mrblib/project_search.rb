module Mrbmacs
  PROJECT_SEARCH_EXCLUDED_DIRECTORIES = ['.git', 'build', 'tmp', 'node_modules'].freeze

  def self.search_project_core(query, root_directory, stats = nil)
    results = []
    files = 0
    directories = [File.expand_path(root_directory)]

    until directories.empty?
      directory = directories.pop
      begin
        Dir.foreach(directory) do |entry|
          next if entry == '.' || entry == '..'

          path = File.join(directory, entry)
          if File.directory?(path)
            next if PROJECT_SEARCH_EXCLUDED_DIRECTORIES.include?(entry)
            next if File.symlink?(path)

            directories << path
            next
          end
          next unless File.file?(path)

          files += 1
          file_results = []
          binary = false
          begin
            File.open(path, 'rb') do |file|
              line_number = 0
              file.each_line do |line|
                line_number += 1
                if line.include?("\0")
                  binary = true
                  break
                end
                next unless line.include?(query)

                file_results << {
                  'file' => path,
                  'line' => line_number,
                  'text' => line.chomp
                }
              end
            end
            results.concat(file_results) unless binary
          rescue StandardError
            next
          end
        end
      rescue StandardError
        next
      end
    end

    stats['files'] = files unless stats.nil?
    results
  end

  # Command
  module Command
    describe_command :search_project, 'Search the current project for a literal string.'

    def search_project
      unless @project && Dir.exist?(@project.root_directory)
        message 'Project is not available'
        return
      end

      query = @frame.echo_gets('Search project: ', search_project_word_at_cursor)
      return if query.nil? || query.empty?

      stats = {}
      started_at = Time.now
      results = Mrbmacs.search_project_core(query, @project.root_directory, stats)
      elapsed = Time.now - started_at
      @logger.debug format(
        'search_project query=%p files=%d matches=%d elapsed=%.3f',
        query, stats['files'], results.length, elapsed
      )
      display_project_search_results(query, results, elapsed)
    end

  end

  class Application
    def search_project_word_at_cursor
      view = @frame.view_win
      position = view.sci_get_current_pos
      word_start = view.sci_word_start_position(position, true)
      word_end = view.sci_word_end_position(position, true)
      return '' if word_start == word_end

      view.sci_get_text_range(word_start, word_end)
    end

    def display_project_search_results(query, results, elapsed)
      root = @project.root_directory
      text = "Project Search: #{query}\n" \
             "Project: #{@project.name}\n" \
             "Root: #{root}\n" \
             "Matches: #{results.length}\n" \
             "Elapsed: #{format('%.3f', elapsed)} sec\n\n"
      path_prefix = root.end_with?(File::SEPARATOR) ? root : root + File::SEPARATOR
      results.each do |result|
        relative_path = if result['file'].start_with?(path_prefix)
                          result['file'][path_prefix.length..-1]
                        else
                          result['file']
                        end
        text << "#{relative_path}:#{result['line']}:#{result['text']}\n"
      end

      setup_result_buffer('*Project Search*')
      @current_buffer.mode.pattern = Regexp.escape(query)
      @current_buffer.mode.root_directory = root
      view = @frame.view_win
      view.sci_set_read_only(0)
      view.sci_set_text(text)
      view.sci_set_save_point
      view.sci_set_read_only(1)
      view.sci_goto_pos(0)
    end
  end
end
