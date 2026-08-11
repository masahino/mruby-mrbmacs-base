module Mrbmacs
  class RustMode < Mode
    def initialize
      super
      @name = 'rust'
      @lexer_profile = RUST_LEXER_PROFILE
      @indent = 4
      @start_of_comment = '// '
      @build_command = 'cargo build'
    end

    def end_of_block?(line)
      if line =~ /^\s*}.*$/
        true
      else
        false
      end
    end
  end
end
