module Mrbmacs
  class JavascriptMode < CLikeMode
    def initialize
      super
      @name = 'javascript'
      @lexer_profile = JAVASCRIPT_LEXER_PROFILE
      @start_of_comment = '/* '
      @end_of_comment = ' */'
    end
  end
end
