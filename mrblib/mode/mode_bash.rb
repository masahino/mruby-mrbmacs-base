module Mrbmacs
  # Bash mode
  class BashMode < Mode
    def initialize
      super
      @name = 'bash'
      @lexer_profile = BASH_LEXER_PROFILE
      @start_of_comment = '# '
    end

    def end_of_block?(line)
      if line =~ /^\s*(end|else|fi|done|}).*$/
        true
      else
        false
      end
    end
  end
end
