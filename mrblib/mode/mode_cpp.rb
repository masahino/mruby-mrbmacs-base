module Mrbmacs
  class CppMode < Mode
    def initialize
      super.initialize
      @name = 'cpp'
      @lexer = 'cpp'
      @keyword_list = 'and and_eq asm auto bitand bitor bool break case catch char class compl const const_cast constexpr continue default delete do double dynamic_cast else enum explicit export extern false float for friend goto if inline int long mutable namespace new not not_eq operator or or_eq private protected public register reinterpret_cast return short signed sizeof static static_cast struct switch template this throw true try typedef typeid typename union unsigned using virtual void volatile wchar_t while xor xor_eq'
      @start_of_comment = '/* '
      @end_of_comment = ' */'
      @style = [
        :color_foreground, # SCE_C_DEFAULT 0
        :color_comment, # SCE_C_COMMENT 1
        :color_comment, # SCE_C_COMMENTLINE 2
        :color_comment, # SCE_C_COMMENTDOC 3
        :color_foreground, # SCE_C_NUMBER 4
        :color_keyword, # SCE_C_WORD 5
        :color_string, # SCE_C_STRING 6
        :color_foreground, # SCE_C_CHARACTER 7
        :color_foreground, # SCE_C_UUID 8
        :color_preprocessor, # SCE_C_PREPROCESSOR 9
        :color_foreground, # SCE_C_OPERATOR 10
        :color_foreground, # SCE_C_IDENTIFIER 11
        :color_string, # SCE_C_STRINGEOL 21
        :color_foreground, # SCE_C_VERBATIM 13
        :color_regexp_grouping_construct, # SCE_C_REGEX 14
        :color_comment, # SCE_C_COMMENTLINEDOC 15
        :color_keyword, # SCE_C_WORD2 16
        :color_comment, # SCE_C_COMMENTDOCKEYWORD 17
        :color_comment, # SCE_C_COMMENTDOCKEYWORDERROR 18
        :color_foreground, # SCE_C_GLOBALCLASS 19
        :color_string, # SCE_C_STRINGRAW 20
        :color_foreground, # SCE_C_TRIPLEVERBATIM 21
        :color_string, # SCE_C_HASHQUOTEDSTRING 22
        :color_comment, # SCE_C_PREPROCESSORCOMMENT 23
        :color_comment, # SCE_C_PREPROCESSORCOMMENTDOC 24
        :color_foreground, # SCE_C_USERLITERAL 25
        :color_foreground, # SCE_C_TASKMARKER 26
        :color_negation_char # SCE_C_ESCAPESEQUENCE 27
      ]
    end

    def set_style(view_win, theme)
      super
      view_win.sci_set_property('lexer.cpp.track.preprocessor', '0')
    end

    def is_end_of_block(line)
      if line =~ /^\s*}.*$/
        true
      else
        false
      end
    end
  end
end
