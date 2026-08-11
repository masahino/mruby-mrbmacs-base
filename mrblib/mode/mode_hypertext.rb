module Mrbmacs
  class HtmlMode < Mode
    def initialize
      super
      @name = 'html'
      @lexer_profile = HTML_LEXER_PROFILE
      @start_of_comment = '<!-- '
      @end_of_comment = ' -->'
    end

    def end_of_block?(line)
      line =~ %r{^\s*</.*>\s*$} ? true : false
    end

    def completion_keyword_list
      ''
    end
  end
end
