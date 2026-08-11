module Mrbmacs
  # configuration of mrbmacs
  class Config
    attr_accessor :theme, :ext, :use_builtin_completion, :use_builtin_indent, :use_builtin_syntax_check,
                  :file_encodings, :styles

    def initialize
      @use_builtin_completion = false
      @use_builtin_indent = false
      @use_builtin_syntax_check = false
      @theme = Base16DefaultDarkTheme
      @styles = StyleOverrides.new
      @ext = {}
      @file_encodings = []
    end
  end
end
