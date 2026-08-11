module Mrbmacs
  class LispMode < Mode
    def initialize
      super
      @name = 'lisp'
      @lexer_profile = LISP_LEXER_PROFILE
      @start_of_comment = '; '
    end
  end
end
