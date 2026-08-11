module Mrbmacs
  class LuaMode < Mode
    def initialize
      super
      @name = 'lua'
      @lexer_profile = LUA_LEXER_PROFILE
      @start_of_comment = '# '
    end

    def end_of_block?(line)
      if line =~ /^\s*(end|else}).*$/
        true
      else
        false
      end
    end
  end
end
