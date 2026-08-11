module Mrbmacs
  class GoMode < CLikeMode
    def initialize
      super
      @indent = 4
      @name = 'go'
      @lexer_profile = GO_LEXER_PROFILE
      @use_tabs = true
      @tab_indent = 8
      @start_of_comment = '// '
    end
  end
end
