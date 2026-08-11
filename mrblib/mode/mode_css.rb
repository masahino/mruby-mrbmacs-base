module Mrbmacs
  class CssMode < Mode
    def initialize
      super
      @name = 'css'
      @lexer_profile = CSS_LEXER_PROFILE
      @start_of_comment = '/* '
      @end_of_comment = ' */'
    end
  end
end
