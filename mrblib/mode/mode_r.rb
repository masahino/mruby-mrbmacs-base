module Mrbmacs
  class RMode < Mode
    def initialize
      super
      @name = 'r'
      @lexer_profile = R_LEXER_PROFILE
      @start_of_comment = '# '
    end

    def end_of_block?(line)
      if line =~ /^\s*}.*$/
        true
      else
        false
      end
    end
  end
end
