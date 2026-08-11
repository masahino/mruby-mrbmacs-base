module Mrbmacs
  class TypescriptMode < CLikeMode
    def initialize
      super
      @name = 'typescript'
      @lexer_profile = TYPESCRIPT_LEXER_PROFILE
      @start_of_comment = '/* '
      @end_of_comment = ' */'
    end
  end
end
