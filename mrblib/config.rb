module Mrbmacs
  # configuration of mrbmacs
  class Config
    attr_accessor :theme, :ext, :use_builtin_indent, :file_encodings, :styles

    def initialize
      @use_builtin_indent = false
      @theme = Base16DefaultDarkTheme
      @styles = StyleOverrides.new
      @ext = {}
      @file_encodings = []
    end
  end
end
