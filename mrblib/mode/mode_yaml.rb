module Mrbmacs
  class YamlMode < Mode
    def initialize
      super
      @name = 'yaml'
      @lexer_profile = YAML_LEXER_PROFILE
    end
  end
end
