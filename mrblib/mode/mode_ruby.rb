module Mrbmacs
  # ruby-mode
  class RubyMode < Mode
    def initialize
      super
      @name = 'ruby'
      @start_of_comment = '# '
      @lexer_profile = RUBY_LEXER_PROFILE
    end

    def get_indent(view_win)
      view_win.sci_get_indent * get_indent_level(view_win)
    end

    def end_of_block?(line)
      if line =~ /^\s*(end|else|then|elsif|when|rescue|ensure|when|\}|\]|\)).*$/
        true
      else
        false
      end
    end
  end
end
