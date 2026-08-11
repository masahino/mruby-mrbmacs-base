module Mrbmacs
  class XmlMode < Mode
    def initialize
      super
      @name = 'xml'
      @lexer_profile = XML_LEXER_PROFILE
    end

    def end_of_block?(line)
      line =~ %r{^\s*</.*>\s*$} ? true : false
    end
  end
end
