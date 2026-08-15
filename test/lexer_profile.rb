module Mrbmacs
  module TestSupport
    class LexerProfileView
      attr_reader :calls

      def initialize
        @calls = []
      end

      def sci_set_lexer_language(lexer)
        @calls << [:lexer, lexer]
      end

      def sci_set_property(name, value)
        @calls << [:property, name, value]
      end

      def sci_set_keywords(index, keywords)
        @calls << [:keywords, index, keywords]
      end
    end
  end
end

assert('container LexerProfile applies without selecting a Lexilla lexer') do
  profile = Mrbmacs::LexerProfile.new(:container, nil, { 0 => :default })
  view = Mrbmacs::TestSupport::LexerProfileView.new

  profile.apply(view)

  assert_equal [], view.calls
end

assert('LexerProfile applies lexer configuration in order') do
  profile = Mrbmacs::LexerProfile.new(
    :test,
    'cpp',
    {},
    { 0 => 'class struct', 1 => 'size_t' },
    { 'fold' => '1' }
  )
  view = Mrbmacs::TestSupport::LexerProfileView.new

  profile.apply(view)

  assert_equal [
    [:lexer, 'cpp'],
    [:property, 'fold', '1'],
    [:keywords, 0, 'class struct'],
    [:keywords, 1, 'size_t']
  ], view.calls
end

assert('MakeMode uses the Lexilla makefile lexer') do
  mode = Mrbmacs::MakeMode.new
  view = Mrbmacs::TestSupport::LexerProfileView.new

  mode.apply_lexer(view)

  assert_equal 'makefile', mode.lexer_profile.lexer
  assert_equal [:lexer, 'makefile'], view.calls[0]
end

assert('migrated modes use lexer profiles') do
  modes_and_profiles = {
    Mrbmacs::BashMode => Mrbmacs::BASH_LEXER_PROFILE,
    Mrbmacs::CppMode => Mrbmacs::CPP_LEXER_PROFILE,
    Mrbmacs::CompilationMode => Mrbmacs::COMPILATION_LEXER_PROFILE,
    Mrbmacs::CssMode => Mrbmacs::CSS_LEXER_PROFILE,
    Mrbmacs::DiffMode => Mrbmacs::DIFF_LEXER_PROFILE,
    Mrbmacs::FundamentalMode => Mrbmacs::FUNDAMENTAL_LEXER_PROFILE,
    Mrbmacs::GrepMode => Mrbmacs::GREP_LEXER_PROFILE,
    Mrbmacs::GoMode => Mrbmacs::GO_LEXER_PROFILE,
    Mrbmacs::HaskellMode => Mrbmacs::HASKELL_LEXER_PROFILE,
    Mrbmacs::HtmlMode => Mrbmacs::HTML_LEXER_PROFILE,
    Mrbmacs::JavaMode => Mrbmacs::JAVA_LEXER_PROFILE,
    Mrbmacs::JavascriptMode => Mrbmacs::JAVASCRIPT_LEXER_PROFILE,
    Mrbmacs::JsonMode => Mrbmacs::JSON_LEXER_PROFILE,
    Mrbmacs::LispMode => Mrbmacs::LISP_LEXER_PROFILE,
    Mrbmacs::LuaMode => Mrbmacs::LUA_LEXER_PROFILE,
    Mrbmacs::MakeMode => Mrbmacs::MAKE_LEXER_PROFILE,
    Mrbmacs::MarkdownMode => Mrbmacs::MARKDOWN_LEXER_PROFILE,
    Mrbmacs::ObjectivecMode => Mrbmacs::OBJECTIVEC_LEXER_PROFILE,
    Mrbmacs::PerlMode => Mrbmacs::PERL_LEXER_PROFILE,
    Mrbmacs::PovMode => Mrbmacs::POV_LEXER_PROFILE,
    Mrbmacs::RMode => Mrbmacs::R_LEXER_PROFILE,
    Mrbmacs::RustMode => Mrbmacs::RUST_LEXER_PROFILE,
    Mrbmacs::LatexMode => Mrbmacs::TEX_LEXER_PROFILE,
    Mrbmacs::TypescriptMode => Mrbmacs::TYPESCRIPT_LEXER_PROFILE,
    Mrbmacs::XmlMode => Mrbmacs::XML_LEXER_PROFILE,
    Mrbmacs::YamlMode => Mrbmacs::YAML_LEXER_PROFILE
  }

  modes_and_profiles.each do |mode_class, profile|
    assert_equal profile, mode_class.new.lexer_profile
    assert_true profile.styles.length > 0
  end
end

assert('migrated lexer profiles own Lexilla configuration') do
  profiles = [
    Mrbmacs::BASH_LEXER_PROFILE,
    Mrbmacs::CPP_LEXER_PROFILE,
    Mrbmacs::COMPILATION_LEXER_PROFILE,
    Mrbmacs::CSS_LEXER_PROFILE,
    Mrbmacs::DIFF_LEXER_PROFILE,
    Mrbmacs::FUNDAMENTAL_LEXER_PROFILE,
    Mrbmacs::GREP_LEXER_PROFILE,
    Mrbmacs::GO_LEXER_PROFILE,
    Mrbmacs::HASKELL_LEXER_PROFILE,
    Mrbmacs::HTML_LEXER_PROFILE,
    Mrbmacs::JAVA_LEXER_PROFILE,
    Mrbmacs::JAVASCRIPT_LEXER_PROFILE,
    Mrbmacs::JSON_LEXER_PROFILE,
    Mrbmacs::LISP_LEXER_PROFILE,
    Mrbmacs::LUA_LEXER_PROFILE,
    Mrbmacs::MAKE_LEXER_PROFILE,
    Mrbmacs::MARKDOWN_LEXER_PROFILE,
    Mrbmacs::OBJECTIVEC_LEXER_PROFILE,
    Mrbmacs::PERL_LEXER_PROFILE,
    Mrbmacs::POV_LEXER_PROFILE,
    Mrbmacs::R_LEXER_PROFILE,
    Mrbmacs::RUST_LEXER_PROFILE,
    Mrbmacs::TEX_LEXER_PROFILE,
    Mrbmacs::TYPESCRIPT_LEXER_PROFILE,
    Mrbmacs::XML_LEXER_PROFILE,
    Mrbmacs::YAML_LEXER_PROFILE
  ]

  profiles.each do |profile|
    assert_true profile.lexer.length > 0 unless profile.lexer.nil?
    assert_true profile.keyword_sets.key?(0) unless profile.keyword_sets.empty?
    profile.styles.each_value do |role|
      assert_equal role, Mrbmacs::StyleRole.normalize(role)
    end
  end
end

assert('reviewed lexer mappings preserve semantic improvements') do
  expected_roles = {
    Mrbmacs::BASH_LEXER_PROFILE => {
      Scintilla::SCE_SH_PARAM => :variable_name,
      Scintilla::SCE_SH_ERROR => :error
    },
    Mrbmacs::CPP_LEXER_PROFILE => {
      Scintilla::SCE_C_COMMENTDOC => :documentation,
      Scintilla::SCE_C_ESCAPESEQUENCE => :escape
    },
    Mrbmacs::CSS_LEXER_PROFILE => {
      Scintilla::SCE_CSS_CLASS => :variable_name,
      Scintilla::SCE_CSS_UNKNOWN_IDENTIFIER => :error
    },
    Mrbmacs::DIFF_LEXER_PROFILE => {
      Scintilla::SCE_DIFF_ADDED => :diff_added,
      Scintilla::SCE_DIFF_DELETED => :diff_deleted
    },
    Mrbmacs::COMPILATION_LEXER_PROFILE => {
      Mrbmacs::COMPILATION_STYLE_ERROR => :error,
      Mrbmacs::COMPILATION_STYLE_FILE => :markup_link
    },
    Mrbmacs::GREP_LEXER_PROFILE => {
      Mrbmacs::GREP_STYLE_FILE => :markup_link,
      Mrbmacs::GREP_STYLE_PATTERN => :warning
    },
    Mrbmacs::GO_LEXER_PROFILE => {
      Scintilla::SCE_C_NUMBER => :number,
      Scintilla::SCE_C_OPERATOR => :operator
    },
    Mrbmacs::JAVA_LEXER_PROFILE => {
      Scintilla::SCE_C_WORD2 => :type,
      Scintilla::SCE_C_COMMENTDOCKEYWORD => :documentation_markup
    },
    Mrbmacs::JAVASCRIPT_LEXER_PROFILE => {
      Scintilla::SCE_C_WORD2 => :builtin,
      Scintilla::SCE_C_REGEX => :regexp
    },
    Mrbmacs::OBJECTIVEC_LEXER_PROFILE => {
      Scintilla::SCE_C_WORD2 => :type,
      Scintilla::SCE_C_PREPROCESSOR => :preprocessor
    },
    Mrbmacs::TYPESCRIPT_LEXER_PROFILE => {
      Scintilla::SCE_C_WORD2 => :type,
      Scintilla::SCE_C_REGEX => :regexp
    },
    Mrbmacs::HASKELL_LEXER_PROFILE => {
      Scintilla::SCE_HA_CLASS => :type,
      Scintilla::SCE_HA_PRAGMA => :preprocessor
    },
    Mrbmacs::HTML_LEXER_PROFILE => {
      Scintilla::SCE_H_ATTRIBUTE => :property_name,
      Scintilla::SCE_HJ_REGEX => :regexp,
      Scintilla::SCE_HP_DEFNAME => :function_name,
      Scintilla::SCE_HPHP_VARIABLE => :variable_name
    },
    Mrbmacs::JSON_LEXER_PROFILE => {
      Scintilla::SCE_JSON_PROPERTYNAME => :variable_name,
      Scintilla::SCE_JSON_URI => :markup_link
    },
    Mrbmacs::LISP_LEXER_PROFILE => {
      Scintilla::SCE_LISP_SYMBOL => :function_name,
      Scintilla::SCE_LISP_NUMBER => :number
    },
    Mrbmacs::LUA_LEXER_PROFILE => {
      Scintilla::SCE_LUA_COMMENTDOC => :documentation,
      Scintilla::SCE_LUA_LABEL => :label
    },
    Mrbmacs::MAKE_LEXER_PROFILE => {
      Scintilla::SCE_MAKE_TARGET => :function_name,
      Scintilla::SCE_MAKE_IDEOL => :error
    },
    Mrbmacs::MARKDOWN_LEXER_PROFILE => {
      Scintilla::SCE_MARKDOWN_HEADER1 => :markup_heading,
      Scintilla::SCE_MARKDOWN_CODEBK => :markup_code
    },
    Mrbmacs::PERL_LEXER_PROFILE => {
      Scintilla::SCE_PL_REGEX => :regexp,
      Scintilla::SCE_PL_STRING_VAR => :variable_name
    },
    Mrbmacs::POV_LEXER_PROFILE => {
      Scintilla::SCE_POV_DIRECTIVE => :preprocessor,
      Scintilla::SCE_POV_BADDIRECTIVE => :error
    },
    Mrbmacs::R_LEXER_PROFILE => {
      Scintilla::SCE_R_NUMBER => :number,
      Scintilla::SCE_R_INFIX => :operator
    },
    Mrbmacs::RUST_LEXER_PROFILE => {
      Scintilla::SCE_RUST_COMMENTLINEDOC => :documentation,
      Scintilla::SCE_RUST_MACRO => :builtin
    },
    Mrbmacs::TEX_LEXER_PROFILE => {
      Scintilla::SCE_L_MATH => :constant,
      Scintilla::SCE_L_ERROR => :error
    },
    Mrbmacs::XML_LEXER_PROFILE => {
      Scintilla::SCE_H_CDATA => :string,
      Scintilla::SCE_H_ENTITY => :constant,
      Scintilla::SCE_H_SGML_ERROR => :error
    },
    Mrbmacs::YAML_LEXER_PROFILE => {
      Scintilla::SCE_YAML_DOCUMENT => :constant,
      Scintilla::SCE_YAML_ERROR => :error
    }
  }

  expected_roles.each do |profile, styles|
    styles.each do |style, role|
      assert_equal role, profile.styles[style]
    end
  end
end

assert('migrated profiles preserve lexer properties') do
  assert_equal({ 'fold.compact' => '1' }, Mrbmacs::BASH_LEXER_PROFILE.properties)
  assert_equal({
      'fold' => '1',
      'lexer.cpp.track.preprocessor' => '0',
      'lexer.cpp.escape.sequence' => '1'
    }, Mrbmacs::CPP_LEXER_PROFILE.properties)
  assert_equal({
      'lexer.cpp.backquoted.strings' => '1',
      'lexer.cpp.escape.sequence' => '1'
    }, Mrbmacs::GO_LEXER_PROFILE.properties)
  assert_equal '0', Mrbmacs::JAVA_LEXER_PROFILE.properties['lexer.cpp.enable.preprocessor']
  assert_equal '1', Mrbmacs::JAVA_LEXER_PROFILE.properties['lexer.cpp.triplequoted.strings']
  assert_equal '1', Mrbmacs::JAVASCRIPT_LEXER_PROFILE.properties['lexer.cpp.allow.dollars']
  assert_equal '2', Mrbmacs::JAVASCRIPT_LEXER_PROFILE.properties['lexer.cpp.backquoted.strings']
  assert_equal '0', Mrbmacs::OBJECTIVEC_LEXER_PROFILE.properties['lexer.cpp.track.preprocessor']
  assert_equal '1', Mrbmacs::TYPESCRIPT_LEXER_PROFILE.properties['lexer.cpp.allow.dollars']
  assert_equal '2', Mrbmacs::TYPESCRIPT_LEXER_PROFILE.properties['lexer.cpp.backquoted.strings']
  assert_equal '1', Mrbmacs::HTML_LEXER_PROFILE.properties['fold.html']
  assert_equal '1', Mrbmacs::XML_LEXER_PROFILE.properties['html.tags.case.sensitive']
  assert_equal '0', Mrbmacs::XML_LEXER_PROFILE.properties['lexer.xml.allow.scripts']
  assert_equal({}, Mrbmacs::JSON_LEXER_PROFILE.properties)
end

assert('profile identity follows the mrbmacs language mode') do
  assert_equal :go, Mrbmacs::GO_LEXER_PROFILE.name
  assert_equal 'cpp', Mrbmacs::GO_LEXER_PROFILE.lexer
  assert_equal :java, Mrbmacs::JAVA_LEXER_PROFILE.name
  assert_equal 'cpp', Mrbmacs::JAVA_LEXER_PROFILE.lexer
  assert_equal :javascript, Mrbmacs::JAVASCRIPT_LEXER_PROFILE.name
  assert_equal 'cpp', Mrbmacs::JAVASCRIPT_LEXER_PROFILE.lexer
  assert_equal :objectivec, Mrbmacs::OBJECTIVEC_LEXER_PROFILE.name
  assert_equal 'cpp', Mrbmacs::OBJECTIVEC_LEXER_PROFILE.lexer
  assert_equal :typescript, Mrbmacs::TYPESCRIPT_LEXER_PROFILE.name
  assert_equal 'cpp', Mrbmacs::TYPESCRIPT_LEXER_PROFILE.lexer
  assert_equal :html, Mrbmacs::HTML_LEXER_PROFILE.name
  assert_equal 'hypertext', Mrbmacs::HTML_LEXER_PROFILE.lexer
  assert_equal :xml, Mrbmacs::XML_LEXER_PROFILE.name
  assert_equal 'xml', Mrbmacs::XML_LEXER_PROFILE.lexer
  assert_equal :compilation, Mrbmacs::COMPILATION_LEXER_PROFILE.name
  assert_nil Mrbmacs::COMPILATION_LEXER_PROFILE.lexer
  assert_equal :grep, Mrbmacs::GREP_LEXER_PROFILE.name
  assert_nil Mrbmacs::GREP_LEXER_PROFILE.lexer
  assert_equal 'indent', Mrbmacs::FUNDAMENTAL_LEXER_PROFILE.lexer
  assert_equal :latex, Mrbmacs::TEX_LEXER_PROFILE.name
  assert_equal 'latex', Mrbmacs::TEX_LEXER_PROFILE.lexer
end

assert('profile keyword set 0 remains the completion fallback') do
  assert_true Mrbmacs::CppMode.new.completion_keyword_list.include?('constexpr')
  assert_true Mrbmacs::GoMode.new.completion_keyword_list.include?('func')
  assert_true Mrbmacs::JavaMode.new.completion_keyword_list.include?('interface')
  assert_true Mrbmacs::JavascriptMode.new.completion_keyword_list.include?('function')
  assert_true Mrbmacs::ObjectivecMode.new.completion_keyword_list.include?('@interface')
  assert_true Mrbmacs::TypescriptMode.new.completion_keyword_list.include?('interface')
  assert_false Mrbmacs::TypescriptMode.new.completion_keyword_list.include?('constexpr')
  assert_false Mrbmacs::JavaMode.new.completion_keyword_list.include?('constexpr')
  assert_false Mrbmacs::JavascriptMode.new.completion_keyword_list.include?('constexpr')
  assert_equal '', Mrbmacs::HtmlMode.new.completion_keyword_list
  assert_equal '', Mrbmacs::XmlMode.new.completion_keyword_list
  assert_true Mrbmacs::PerlMode.new.completion_keyword_list.include?('sub')
  assert_equal '', Mrbmacs::JsonMode.new.completion_keyword_list
end
