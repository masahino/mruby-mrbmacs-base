module Mrbmacs
  class PovMode < Mode
    def initialize
      super
      @name = 'pov'
      @lexer_profile = POV_LEXER_PROFILE
      @start_of_comment = '# '
    end
  end
end
