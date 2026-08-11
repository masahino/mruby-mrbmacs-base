module Mrbmacs
  class PythonMode < Mode
    def initialize
      super
      @indent = 4
      @name = 'python'
      @use_tabs = false
      @start_of_comment = '# '
      @lexer_profile = PYTHON_LEXER_PROFILE
    end

    def end_of_block?(_line)
      false
    end
  end
end
