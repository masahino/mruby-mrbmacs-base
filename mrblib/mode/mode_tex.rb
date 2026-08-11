module Mrbmacs
  class LatexMode < Mode
    def initialize
      super
      @name = 'latex'
      @lexer_profile = TEX_LEXER_PROFILE
      @start_of_comment = '% '
    end
  end
end
