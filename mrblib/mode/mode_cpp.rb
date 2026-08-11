module Mrbmacs
  class CppMode < CLikeMode
    def initialize
      super
      @name = 'cpp'
      @lexer_profile = CPP_LEXER_PROFILE
      @start_of_comment = '/* '
      @end_of_comment = ' */'
    end
  end
end
