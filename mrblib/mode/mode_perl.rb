module Mrbmacs
  class PerlMode < Mode
    def initialize
      super
      @name = 'perl'
      @lexer_profile = PERL_LEXER_PROFILE
      @start_of_comment = '# '
    end
  end
end
