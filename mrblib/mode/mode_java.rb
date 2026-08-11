module Mrbmacs
  class JavaMode < CLikeMode
    def initialize
      super
      @name = 'java'
      @lexer_profile = JAVA_LEXER_PROFILE
      @start_of_comment = '/* '
      @end_of_comment = ' */'
    end
  end
end
