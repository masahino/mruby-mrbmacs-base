module Mrbmacs
  # Scintilla/Lexilla configuration independent from concrete theme colours.
  class LexerProfile
    attr_reader :name, :lexer, :styles, :keyword_sets, :properties

    def initialize(name, lexer, styles, keyword_sets = {}, properties = {})
      @name = name
      @lexer = lexer
      @styles = styles
      @keyword_sets = keyword_sets
      @properties = properties
    end

    def apply(view)
      view.sci_set_lexer_language(@lexer) unless @lexer.nil?
      @properties.each do |property, value|
        view.sci_set_property(property, value)
      end
      @keyword_sets.each do |index, keywords|
        view.sci_set_keywords(index, keywords)
      end
    end
  end
end
