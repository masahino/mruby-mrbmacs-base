module Mrbmacs
  # Command
  module Command
    describe_command :dmacro_exec, 'Repeat the most recent key sequence dynamically.'

    def dmacro_exec
      return if @recent_keys.length < 2
      if @recent_keys[@recent_keys.length - 2] != 'C-t'
        @dmacro_repeated_keys = dmacro_find_rep(@recent_keys[0..@recent_keys.length - 2])
      end
      prefix = ''
      @dmacro_repeated_keys.each do |key|
        key = prefix + key
        command = key_scan(key)
        if !command.nil?
          if command.is_a?(Integer)
            @frame.view_win.send_message(command, nil, nil)
            next
          end
          if command == 'prefix'
            prefix += "#{key} "
            next
          end

          extend(command)
        else
          @frame.view_win.sci_add_text(key.length, key)
        end
        prefix = ''
      end
    end

  end

  # Application
  class Application
    def dmacro_find_rep(ary)
      len = ary.length
      res = []
      for i in 0..len / 2
        match = true
        for j in 0..i
          if ary[len - 2 - i - j] != ary[len - 1 - j]
            match = false
            break
          end
        end
        res = ary[len - j - 1..len - 1] if match
      end
      res
    end
  end
end
