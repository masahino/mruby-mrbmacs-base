module Mrbmacs
  XML_SGML_KEYWORDS = 'ATTLIST DOCTYPE ELEMENT ENTITY FIXED ID IDREF IDREFS IMPLIED NDATA NOTATION PCDATA PUBLIC REQUIRED SYSTEM'

  XML_LEXER_PROFILE = LexerProfile.new(
    :xml,
    'xml',
    {
      Scintilla::SCE_H_DEFAULT => :default,
      Scintilla::SCE_H_TAG => :keyword,
      Scintilla::SCE_H_TAGUNKNOWN => :error,
      Scintilla::SCE_H_ATTRIBUTE => :property_name,
      Scintilla::SCE_H_ATTRIBUTEUNKNOWN => :error,
      Scintilla::SCE_H_NUMBER => :number,
      Scintilla::SCE_H_DOUBLESTRING => :string,
      Scintilla::SCE_H_SINGLESTRING => :string,
      Scintilla::SCE_H_OTHER => :default,
      Scintilla::SCE_H_COMMENT => :comment,
      Scintilla::SCE_H_ENTITY => :constant,
      Scintilla::SCE_H_TAGEND => :keyword,
      Scintilla::SCE_H_XMLSTART => :preprocessor,
      Scintilla::SCE_H_XMLEND => :preprocessor,
      Scintilla::SCE_H_SCRIPT => :default,
      Scintilla::SCE_H_ASP => :default,
      Scintilla::SCE_H_ASPAT => :default,
      Scintilla::SCE_H_CDATA => :string,
      Scintilla::SCE_H_QUESTION => :preprocessor,
      Scintilla::SCE_H_VALUE => :string,
      Scintilla::SCE_H_XCCOMMENT => :comment,
      Scintilla::SCE_H_SGML_DEFAULT => :default,
      Scintilla::SCE_H_SGML_COMMAND => :preprocessor,
      Scintilla::SCE_H_SGML_1ST_PARAM => :preprocessor,
      Scintilla::SCE_H_SGML_DOUBLESTRING => :string,
      Scintilla::SCE_H_SGML_SIMPLESTRING => :string,
      Scintilla::SCE_H_SGML_ERROR => :error,
      Scintilla::SCE_H_SGML_SPECIAL => :constant,
      Scintilla::SCE_H_SGML_ENTITY => :constant,
      Scintilla::SCE_H_SGML_COMMENT => :comment,
      Scintilla::SCE_H_SGML_1ST_PARAM_COMMENT => :comment,
      Scintilla::SCE_H_SGML_BLOCK_DEFAULT => :default
    },
    {
      0 => '',
      5 => XML_SGML_KEYWORDS
    },
    {
      'fold' => '1',
      'fold.html' => '1',
      'html.tags.case.sensitive' => '1',
      'lexer.xml.allow.scripts' => '0',
      'lexer.xml.allow.php' => '0',
      'lexer.xml.allow.asp' => '0'
    }
  )
end
