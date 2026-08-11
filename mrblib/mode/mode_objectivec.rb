module Mrbmacs
  class ObjectivecMode < CLikeMode
    def initialize
      super
      @name = 'objectivec'
      @lexer_profile = OBJECTIVEC_LEXER_PROFILE
      @start_of_comment = '/* '
      @end_of_comment = ' */'
    end
  end
end
