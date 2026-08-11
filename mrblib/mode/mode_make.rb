module Mrbmacs
  class MakeMode < Mode
    def initialize
      super
      @name = 'make'
      @lexer_profile = MAKE_LEXER_PROFILE
      @start_of_comment = '# '
    end
  end
end
