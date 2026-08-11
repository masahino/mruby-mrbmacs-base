module Mrbmacs
  class HaskellMode < Mode
    def initialize
      super
      @name = 'haskell'
      @lexer_profile = HASKELL_LEXER_PROFILE
      @start_of_comment = '-- '
    end
  end
end
