module Mrbmacs
  class MarkdownMode < Mode
    def initialize
      super
      @name = 'markdown'
      @lexer_profile = MARKDOWN_LEXER_PROFILE
    end
  end
end
