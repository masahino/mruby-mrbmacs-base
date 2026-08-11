module Mrbmacs
  # Base editing behaviour for modes backed by Lexilla's cpp lexer.
  class CLikeMode < Mode
    def end_of_block?(line)
      line =~ /^\s*}.*$/ ? true : false
    end
  end
end
