module Mrbmacs
  class JsonMode < Mode
    def initialize
      super
      @name = 'json'
      @lexer_profile = JSON_LEXER_PROFILE
    end

    def end_of_block?(line)
      if line =~ /^\s*(\]|}).*$/
        true
      else
        false
      end
    end
  end
end
