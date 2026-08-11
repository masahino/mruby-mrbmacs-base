# Syntax style mapping specification

This document defines the mapping between Lexilla styles, semantic syntax
roles, and theme palette entries. The standalone profiles listed below are
implemented.

## Semantic roles

| Role | Meaning |
|---|---|
| `default` | Unclassified source text |
| `comment` | Ordinary comments |
| `documentation` | Documentation comments and POD |
| `keyword` | Language keywords and control words |
| `type` | Types, classes, modules, interfaces and namespaces |
| `function_name` | Functions, methods and callable targets |
| `builtin` | Language-provided names, macros and built-ins |
| `variable_name` | Variables, parameters, properties and attributes |
| `constant` | Constants, symbols and enum-like values |
| `number` | Numeric literals |
| `string` | Strings, characters, heredocs and verbatim strings |
| `regexp` | Regular expressions |
| `escape` | Escape sequences and substitutions inside literals |
| `operator` | Operators and punctuation with syntactic meaning |
| `preprocessor` | Preprocessor, directive and pragma syntax |
| `label` | Labels, tags and targets |
| `error` | Invalid or unterminated syntax |
| `warning` | Suspicious syntax, unknown names and task markers |
| `markup_heading` | Markup headings |
| `markup_emphasis` | Markup emphasis and strong text |
| `markup_link` | Links, URIs and references |
| `markup_code` | Markup inline and fenced code |
| `diff_added` | Added text |
| `diff_deleted` | Deleted text |
| `diff_changed` | Changed text |

Unknown and unused lexer styles fall back to `default`.

### Application-provided container lexers

Compilation and Grep are lexers implemented in Ruby through
`SCN_STYLENEEDED`, rather than Lexilla modules. Their `LexerProfile` lexer name
is `nil`, while their manually assigned style numbers use the same semantic
resolver as every other profile.

| Profile | Style number | Role |
|---|---:|---|
| Compilation | 0 | `default` |
| Compilation | 1 | `error` |
| Compilation | 2 | `markup_link` |
| Compilation | 3 | `number` |
| Grep | 0 | `default` |
| Grep | 1 | `markup_link` |
| Grep | 2 | `number` |
| Grep | 3 | `warning` |

Fundamental mode uses Lexilla's `indent` lexer and maps style 0 to `default`.

Preview Theme uses a profile without a Lexilla lexer or a static style map. Its
mode displays the theme-resolved semantic syntax roles and the theme's direct
UI settings in separate sections. Language mapping checks remain in
`examples/style-preview/`.

## Theme mapping

### Base16

| Semantic role | Palette/style |
|---|---|
| `default`, `operator` | `base05` |
| `comment`, `documentation` | `base03`, italic |
| `keyword` | `base0E` |
| `type` | `base0A`, bold |
| `function_name`, `markup_link` | `base0D` |
| `builtin` | `base0E` |
| `variable_name`, `error`, `diff_deleted` | `base08` |
| `constant`, `number` | `base09` |
| `string`, `diff_added` | `base0B` |
| `regexp`, `escape` | `base0C` |
| `preprocessor` | `base0D` |
| `label` | `base0A` |
| `warning`, `diff_changed` | `base0A`, bold for warning |
| `markup_heading` | `base0E`, bold |
| `markup_emphasis` | `base0A`, italic or bold as supplied by the lexer |
| `markup_code` | `base0B` |

### Solarized

The same semantic mapping is shared by the dark and light variants. Only the
background and monotone foreground selection changes between variants.

| Semantic role | Palette/style |
|---|---|
| `default`, `operator` | dark: `base0`; light: `base00` |
| `comment`, `documentation` | dark: `base01`; light: `base1`, italic |
| `keyword`, `builtin` | `green` |
| `type`, `label`, `warning` | `yellow` |
| `function_name`, `markup_link`, `variable_name` | `blue` |
| `constant`, `number`, `string`, `markup_code`, `diff_added` | `cyan` |
| `regexp`, `escape`, `preprocessor`, `diff_changed` | `orange` |
| `error`, `diff_deleted` | `red` |
| `markup_heading` | `violet`, bold |
| `markup_emphasis` | `violet`, italic or bold as supplied by the lexer |

## Lexilla mapping

Names in each row map to the semantic role in the first column. Closely
related styles are grouped to keep the mapping reviewable.

### Bash (`bash`)

| Role | Lexilla styles |
|---|---|
| `default` | `SCE_SH_DEFAULT`, `SCE_SH_IDENTIFIER` |
| `comment` | `SCE_SH_COMMENTLINE` |
| `keyword` | `SCE_SH_WORD` |
| `variable_name` | `SCE_SH_PARAM`, `SCE_SH_SCALAR` |
| `number` | `SCE_SH_NUMBER` |
| `string` | `SCE_SH_STRING`, `SCE_SH_CHARACTER`, `SCE_SH_HERE_Q`, `SCE_SH_HERE_DELIM`, `SCE_SH_BACKTICKS` |
| `operator` | `SCE_SH_OPERATOR` |
| `error` | `SCE_SH_ERROR` |

### C and C++ (`cpp` lexer)

| Role | Lexilla styles |
|---|---|
| `default` | `SCE_C_DEFAULT`, `SCE_C_IDENTIFIER` |
| `comment` | `SCE_C_COMMENT`, `SCE_C_COMMENTLINE`, `SCE_C_PREPROCESSORCOMMENT` |
| `documentation` | `SCE_C_COMMENTDOC`, `SCE_C_COMMENTLINEDOC`, `SCE_C_PREPROCESSORCOMMENTDOC` |
| `documentation_markup` | `SCE_C_COMMENTDOCKEYWORD` |
| `keyword` | `SCE_C_WORD`, `SCE_C_WORD2` |
| `type` | `SCE_C_GLOBALCLASS` |
| `number` | `SCE_C_NUMBER`, `SCE_C_UUID`, `SCE_C_USERLITERAL` |
| `string` | `SCE_C_STRING`, `SCE_C_CHARACTER`, `SCE_C_VERBATIM`, `SCE_C_TRIPLEVERBATIM`, `SCE_C_STRINGRAW`, `SCE_C_HASHQUOTEDSTRING` |
| `regexp` | `SCE_C_REGEX` |
| `escape` | `SCE_C_ESCAPESEQUENCE` |
| `operator` | `SCE_C_OPERATOR` |
| `preprocessor` | `SCE_C_PREPROCESSOR` |
| `warning` | `SCE_C_TASKMARKER` |
| `error` | `SCE_C_STRINGEOL`, `SCE_C_COMMENTDOCKEYWORDERROR` |

Go, Java, and JavaScript use this common style table with language-specific
profiles. Go enables raw backquoted strings. Java maps keyword set 1 and
`SCE_C_WORD2` to `type`, enables text blocks and disables preprocessor syntax.
JavaScript maps keyword set 1 and `SCE_C_WORD2` to `builtin`, enables template
literals, dollar/hash identifiers, escapes, and regular-expression detection.
Each profile owns its own keyword and documentation word lists; none inherits
C++ keywords through its Mode class.

### CSS (`css`)

| Role | Lexilla styles |
|---|---|
| `default` | `SCE_CSS_DEFAULT`, `SCE_CSS_VALUE` |
| `comment` | `SCE_CSS_COMMENT` |
| `type` | `SCE_CSS_TAG`, `SCE_CSS_PSEUDOCLASS`, `SCE_CSS_PSEUDOELEMENT`, `SCE_CSS_EXTENDED_PSEUDOCLASS`, `SCE_CSS_EXTENDED_PSEUDOELEMENT` |
| `variable_name` | `SCE_CSS_CLASS`, `SCE_CSS_ID`, `SCE_CSS_ATTRIBUTE`, `SCE_CSS_VARIABLE` |
| `constant` | `SCE_CSS_IDENTIFIER`, `SCE_CSS_IDENTIFIER2`, `SCE_CSS_IDENTIFIER3`, `SCE_CSS_EXTENDED_IDENTIFIER` |
| `string` | `SCE_CSS_DOUBLESTRING`, `SCE_CSS_SINGLESTRING` |
| `keyword` | `SCE_CSS_IMPORTANT`, `SCE_CSS_DIRECTIVE`, `SCE_CSS_GROUP_RULE` |
| `operator` | `SCE_CSS_OPERATOR` |
| `error` | `SCE_CSS_UNKNOWN_IDENTIFIER`, `SCE_CSS_UNKNOWN_PSEUDOCLASS` |

### Diff (`diff`)

| Role | Lexilla styles |
|---|---|
| `default` | `SCE_DIFF_DEFAULT`, `SCE_DIFF_COMMAND` |
| `comment` | `SCE_DIFF_COMMENT` |
| `markup_heading` | `SCE_DIFF_HEADER`, `SCE_DIFF_POSITION` |
| `diff_added` | `SCE_DIFF_ADDED`, `SCE_DIFF_PATCH_ADD` |
| `diff_deleted` | `SCE_DIFF_DELETED`, `SCE_DIFF_PATCH_DELETE`, `SCE_DIFF_REMOVED_PATCH_ADD`, `SCE_DIFF_REMOVED_PATCH_DELETE` |
| `diff_changed` | `SCE_DIFF_CHANGED` |

### Haskell (`haskell`)

| Role | Lexilla styles |
|---|---|
| `default` | `SCE_HA_DEFAULT`, `SCE_HA_IDENTIFIER`, `SCE_HA_CAPITAL` |
| `comment` | `SCE_HA_COMMENTLINE`, `SCE_HA_COMMENTBLOCK`, `SCE_HA_COMMENTBLOCK2`, `SCE_HA_COMMENTBLOCK3`, `SCE_HA_LITERATE_COMMENT` |
| `keyword` | `SCE_HA_KEYWORD`, `SCE_HA_IMPORT`, `SCE_HA_INSTANCE`, `SCE_HA_DATA` |
| `type` | `SCE_HA_CLASS`, `SCE_HA_MODULE` |
| `number` | `SCE_HA_NUMBER` |
| `string` | `SCE_HA_STRING`, `SCE_HA_CHARACTER`, `SCE_HA_STRINGEOL` |
| `operator` | `SCE_HA_OPERATOR`, `SCE_HA_RESERVED_OPERATOR` |
| `preprocessor` | `SCE_HA_PREPROCESSOR`, `SCE_HA_PRAGMA` |
| `markup_code` | `SCE_HA_LITERATE_CODEDELIM` |

### HTML (`hypertext`)

| Role | Lexilla styles |
|---|---|
| `default` | `SCE_H_DEFAULT`, `SCE_H_OTHER`, `SCE_H_SGML_DEFAULT`, `SCE_H_SGML_BLOCK_DEFAULT` |
| `comment` | `SCE_H_COMMENT`, `SCE_H_XCCOMMENT`, `SCE_H_SGML_COMMENT`, `SCE_H_SGML_1ST_PARAM_COMMENT` |
| `keyword` | `SCE_H_TAG`, `SCE_H_TAGEND`, `SCE_H_XMLSTART`, `SCE_H_XMLEND` |
| `variable_name` | `SCE_H_ATTRIBUTE` |
| `number` | `SCE_H_NUMBER` |
| `string` | `SCE_H_DOUBLESTRING`, `SCE_H_SINGLESTRING`, `SCE_H_VALUE`, `SCE_H_CDATA`, `SCE_H_SGML_DOUBLESTRING`, `SCE_H_SGML_SIMPLESTRING` |
| `constant` | `SCE_H_ENTITY`, `SCE_H_SGML_ENTITY`, `SCE_H_SGML_SPECIAL` |
| `preprocessor` | `SCE_H_QUESTION`, `SCE_H_SGML_COMMAND`, `SCE_H_SGML_1ST_PARAM` |
| `error` | `SCE_H_TAGUNKNOWN`, `SCE_H_ATTRIBUTEUNKNOWN`, `SCE_H_SGML_ERROR` |

Embedded JavaScript, Python, VB and PHP styles use the mappings of their
standalone lexer categories: comments to `comment`, words to `keyword`,
numbers to `number`, and strings to `string`,
regexes to `regexp`, PHP variables to `variable_name`, Python class/function
names to `type`/`function_name`, and operators to `operator`. Start and default
styles remain `default`; unterminated embedded strings map to `error`.
The current mruby-scintilla-base binding does not expose the two embedded
JavaScript template-literal constants, so those styles currently use the
resolver's `default` fallback.

The HTML profile owns all six LexHTML word lists: HTML elements/attributes,
JavaScript, VBScript, Python, PHP, and SGML/DTD. These lists configure Lexilla
only; HTML completion remains empty to preserve existing editor behaviour.

### XML (`xml`)

XML has an independent profile even though Lexilla implements it in
`LexHTML.cxx`. Its base style mapping covers tags, attributes, comments,
entities, CDATA, processing instructions, and DTD/SGML constructs. Embedded
script, PHP, and ASP parsing are disabled. Tag matching is case-sensitive.

| Role | Lexilla styles |
|---|---|
| `default` | `SCE_H_DEFAULT`, `SCE_H_OTHER`, `SCE_H_SGML_DEFAULT`, `SCE_H_SGML_BLOCK_DEFAULT` |
| `comment` | `SCE_H_COMMENT`, `SCE_H_XCCOMMENT`, `SCE_H_SGML_COMMENT`, `SCE_H_SGML_1ST_PARAM_COMMENT` |
| `keyword` | `SCE_H_TAG`, `SCE_H_TAGEND` |
| `property_name` | `SCE_H_ATTRIBUTE` |
| `number` | `SCE_H_NUMBER` |
| `string` | `SCE_H_DOUBLESTRING`, `SCE_H_SINGLESTRING`, `SCE_H_VALUE`, `SCE_H_CDATA`, `SCE_H_SGML_DOUBLESTRING`, `SCE_H_SGML_SIMPLESTRING` |
| `constant` | `SCE_H_ENTITY`, `SCE_H_SGML_ENTITY`, `SCE_H_SGML_SPECIAL` |
| `preprocessor` | `SCE_H_XMLSTART`, `SCE_H_XMLEND`, `SCE_H_QUESTION`, `SCE_H_SGML_COMMAND`, `SCE_H_SGML_1ST_PARAM` |
| `error` | `SCE_H_TAGUNKNOWN`, `SCE_H_ATTRIBUTEUNKNOWN`, `SCE_H_SGML_ERROR` |

### JSON (`json`)

| Role | Lexilla styles |
|---|---|
| `default` | `SCE_JSON_DEFAULT` |
| `comment` | `SCE_JSON_LINECOMMENT`, `SCE_JSON_BLOCKCOMMENT` |
| `keyword` | `SCE_JSON_KEYWORD`, `SCE_JSON_LDKEYWORD` |
| `variable_name` | `SCE_JSON_PROPERTYNAME` |
| `number` | `SCE_JSON_NUMBER` |
| `string` | `SCE_JSON_STRING`, `SCE_JSON_STRINGEOL` |
| `escape` | `SCE_JSON_ESCAPESEQUENCE` |
| `markup_link` | `SCE_JSON_URI`, `SCE_JSON_COMPACTIRI` |
| `operator` | `SCE_JSON_OPERATOR` |
| `error` | `SCE_JSON_ERROR` |

### Lisp (`lisp`)

| Role | Lexilla styles |
|---|---|
| `default` | `SCE_LISP_DEFAULT`, `SCE_LISP_IDENTIFIER` |
| `comment` | `SCE_LISP_COMMENT`, `SCE_LISP_MULTI_COMMENT` |
| `keyword` | `SCE_LISP_KEYWORD`, `SCE_LISP_KEYWORD_KW`, `SCE_LISP_SPECIAL` |
| `function_name` | `SCE_LISP_SYMBOL` |
| `number` | `SCE_LISP_NUMBER` |
| `string` | `SCE_LISP_STRING`, `SCE_LISP_STRINGEOL` |
| `operator` | `SCE_LISP_OPERATOR` |

### Lua (`lua`)

| Role | Lexilla styles |
|---|---|
| `default` | `SCE_LUA_DEFAULT`, `SCE_LUA_IDENTIFIER` |
| `comment` | `SCE_LUA_COMMENT`, `SCE_LUA_COMMENTLINE` |
| `documentation` | `SCE_LUA_COMMENTDOC` |
| `keyword` | `SCE_LUA_WORD`, `SCE_LUA_WORD2`, `SCE_LUA_WORD3`, `SCE_LUA_WORD4`, `SCE_LUA_WORD5`, `SCE_LUA_WORD6`, `SCE_LUA_WORD7`, `SCE_LUA_WORD8` |
| `number` | `SCE_LUA_NUMBER` |
| `string` | `SCE_LUA_STRING`, `SCE_LUA_CHARACTER`, `SCE_LUA_LITERALSTRING`, `SCE_LUA_STRINGEOL` |
| `operator` | `SCE_LUA_OPERATOR` |
| `preprocessor` | `SCE_LUA_PREPROCESSOR` |
| `label` | `SCE_LUA_LABEL` |

### Makefile (`makefile`)

| Role | Lexilla styles |
|---|---|
| `default` | `SCE_MAKE_DEFAULT` |
| `comment` | `SCE_MAKE_COMMENT` |
| `variable_name` | `SCE_MAKE_IDENTIFIER` |
| `function_name` | `SCE_MAKE_TARGET` |
| `operator` | `SCE_MAKE_OPERATOR` |
| `preprocessor` | `SCE_MAKE_PREPROCESSOR` |
| `error` | `SCE_MAKE_IDEOL` |

### Markdown (`markdown`)

| Role | Lexilla styles |
|---|---|
| `default` | `SCE_MARKDOWN_DEFAULT`, `SCE_MARKDOWN_LINE_BEGIN` |
| `markup_heading` | `SCE_MARKDOWN_HEADER1`, `SCE_MARKDOWN_HEADER2`, `SCE_MARKDOWN_HEADER3`, `SCE_MARKDOWN_HEADER4`, `SCE_MARKDOWN_HEADER5`, `SCE_MARKDOWN_HEADER6` |
| `markup_emphasis` | `SCE_MARKDOWN_EM1`, `SCE_MARKDOWN_EM2`, `SCE_MARKDOWN_STRONG1`, `SCE_MARKDOWN_STRONG2`, `SCE_MARKDOWN_STRIKEOUT` |
| `markup_code` | `SCE_MARKDOWN_CODE`, `SCE_MARKDOWN_CODE2`, `SCE_MARKDOWN_CODEBK` |
| `markup_link` | `SCE_MARKDOWN_LINK` |
| `string` | `SCE_MARKDOWN_BLOCKQUOTE` |
| `label` | `SCE_MARKDOWN_OLIST_ITEM`, `SCE_MARKDOWN_ULIST_ITEM`, `SCE_MARKDOWN_PRECHAR` |
| `comment` | `SCE_MARKDOWN_HRULE` |

### Perl (`perl`)

| Role | Lexilla styles |
|---|---|
| `default` | `SCE_PL_DEFAULT`, `SCE_PL_IDENTIFIER`, `SCE_PL_PUNCTUATION` |
| `comment` | `SCE_PL_COMMENTLINE` |
| `documentation` | `SCE_PL_POD`, `SCE_PL_POD_VERB` |
| `keyword` | `SCE_PL_WORD` |
| `variable_name` | `SCE_PL_SCALAR`, `SCE_PL_ARRAY`, `SCE_PL_HASH`, `SCE_PL_SYMBOLTABLE`, `SCE_PL_VARIABLE_INDEXER`, and all `*_VAR` styles |
| `number` | `SCE_PL_NUMBER` |
| `string` | `SCE_PL_STRING`, `SCE_PL_CHARACTER`, `SCE_PL_LONGQUOTE`, `SCE_PL_BACKTICKS`, all `SCE_PL_HERE_*`, `SCE_PL_STRING_Q`, `SCE_PL_STRING_QQ`, `SCE_PL_STRING_QW`, `SCE_PL_STRING_QX` |
| `regexp` | `SCE_PL_REGEX`, `SCE_PL_REGSUBST`, `SCE_PL_STRING_QR`, `SCE_PL_XLAT` |
| `operator` | `SCE_PL_OPERATOR` |
| `preprocessor` | `SCE_PL_PREPROCESSOR`, `SCE_PL_DATASECTION`, `SCE_PL_FORMAT`, `SCE_PL_FORMAT_IDENT`, `SCE_PL_SUB_PROTOTYPE` |
| `error` | `SCE_PL_ERROR` |

### POV-Ray (`pov`)

| Role | Lexilla styles |
|---|---|
| `default` | `SCE_POV_DEFAULT`, `SCE_POV_IDENTIFIER` |
| `comment` | `SCE_POV_COMMENT`, `SCE_POV_COMMENTLINE` |
| `keyword` | `SCE_POV_WORD2`, `SCE_POV_WORD3`, `SCE_POV_WORD4`, `SCE_POV_WORD5`, `SCE_POV_WORD6`, `SCE_POV_WORD7`, `SCE_POV_WORD8` |
| `number` | `SCE_POV_NUMBER` |
| `string` | `SCE_POV_STRING`, `SCE_POV_STRINGEOL` |
| `operator` | `SCE_POV_OPERATOR` |
| `preprocessor` | `SCE_POV_DIRECTIVE` |
| `error` | `SCE_POV_BADDIRECTIVE` |

### Python (`python`)

| Role | Lexilla styles |
|---|---|
| `default` | `SCE_P_DEFAULT`, `SCE_P_IDENTIFIER` |
| `comment` | `SCE_P_COMMENTLINE`, `SCE_P_COMMENTBLOCK` |
| `keyword` | `SCE_P_WORD`, `SCE_P_WORD2` |
| `type` | `SCE_P_CLASSNAME` |
| `function_name` | `SCE_P_DEFNAME` |
| `builtin` | `SCE_P_DECORATOR` |
| `number` | `SCE_P_NUMBER` |
| `string` | `SCE_P_STRING`, `SCE_P_CHARACTER`, `SCE_P_TRIPLE`, `SCE_P_TRIPLEDOUBLE`, `SCE_P_FSTRING`, `SCE_P_FCHARACTER`, `SCE_P_FTRIPLE`, `SCE_P_FTRIPLEDOUBLE` |
| `operator` | `SCE_P_OPERATOR` |
| `error` | `SCE_P_STRINGEOL` |
| `property_use` | `SCE_P_ATTRIBUTE` |

This Python mapping is implemented in
[`mrblib/lexer_profiles/python.rb`](../mrblib/lexer_profiles/python.rb). The
profile owns keyword sets 0 and 1 and the `fold` property. Keyword set 1 is
explicitly empty to preserve the previous behaviour.

### R (`r`)

| Role | Lexilla styles |
|---|---|
| `default` | `SCE_R_DEFAULT`, `SCE_R_IDENTIFIER` |
| `comment` | `SCE_R_COMMENT` |
| `keyword` | `SCE_R_KWORD`, `SCE_R_BASEKWORD`, `SCE_R_OTHERKWORD` |
| `number` | `SCE_R_NUMBER` |
| `string` | `SCE_R_STRING`, `SCE_R_STRING2` |
| `operator` | `SCE_R_OPERATOR`, `SCE_R_INFIX`, `SCE_R_INFIXEOL` |

### Ruby (`ruby`)

| Role | Lexilla styles |
|---|---|
| `default` | `SCE_RB_DEFAULT`, `SCE_RB_IDENTIFIER`, `SCE_RB_WORD_DEMOTED` |
| `comment` | `SCE_RB_COMMENTLINE` |
| `documentation` | `SCE_RB_POD`, `SCE_RB_DATASECTION` |
| `keyword` | `SCE_RB_WORD` |
| `type` | `SCE_RB_CLASSNAME`, `SCE_RB_MODULE_NAME` |
| `function_name` | `SCE_RB_DEFNAME` |
| `builtin` | `SCE_RB_STDIN`, `SCE_RB_STDOUT`, `SCE_RB_STDERR` |
| `variable_use` | `SCE_RB_GLOBAL`, `SCE_RB_INSTANCE_VAR`, `SCE_RB_CLASS_VAR` |
| `constant` | `SCE_RB_SYMBOL` |
| `number` | `SCE_RB_NUMBER` |
| `delimiter` | `SCE_RB_HERE_DELIM` |
| `string` | `SCE_RB_STRING`, `SCE_RB_CHARACTER`, `SCE_RB_BACKTICKS`, `SCE_RB_HERE_Q`, `SCE_RB_HERE_QQ`, `SCE_RB_HERE_QX`, `SCE_RB_STRING_Q`, `SCE_RB_STRING_QQ`, `SCE_RB_STRING_QW`, `SCE_RB_STRING_QX`, `SCE_RB_STRING_W`, `SCE_RB_STRING_I`, `SCE_RB_STRING_QI`, `SCE_RB_STRING_QS` |
| `regexp` | `SCE_RB_REGEX`, `SCE_RB_STRING_QR` |
| `operator` | `SCE_RB_OPERATOR` |
| `error` | `SCE_RB_ERROR` |

`SCE_RB_UPPER_BOUND` is a boundary constant, not a display style.

This Ruby mapping is implemented in
[`mrblib/lexer_profiles/ruby.rb`](../mrblib/lexer_profiles/ruby.rb). The profile
also owns Ruby keyword set 0 and the `fold` property. Ruby Mode retains editing
behaviour and uses the profile keyword list as its current completion fallback.

### Rust (`rust`)

| Role | Lexilla styles |
|---|---|
| `default` | `SCE_RUST_DEFAULT`, `SCE_RUST_IDENTIFIER` |
| `comment` | `SCE_RUST_COMMENTLINE`, `SCE_RUST_COMMENTBLOCK` |
| `documentation` | `SCE_RUST_COMMENTLINEDOC`, `SCE_RUST_COMMENTBLOCKDOC` |
| `keyword` | `SCE_RUST_WORD`, `SCE_RUST_WORD2`, `SCE_RUST_WORD3`, `SCE_RUST_WORD4`, `SCE_RUST_WORD5`, `SCE_RUST_WORD6`, `SCE_RUST_WORD7` |
| `builtin` | `SCE_RUST_MACRO` |
| `variable_name` | `SCE_RUST_LIFETIME` |
| `number` | `SCE_RUST_NUMBER` |
| `string` | `SCE_RUST_STRING`, `SCE_RUST_STRINGR`, `SCE_RUST_CHARACTER`, `SCE_RUST_BYTESTRING`, `SCE_RUST_BYTESTRINGR`, `SCE_RUST_BYTECHARACTER` |
| `operator` | `SCE_RUST_OPERATOR` |
| `error` | `SCE_RUST_LEXERROR` |

### LaTeX (`latex`)

| Role | Lexilla styles |
|---|---|
| `default` | `SCE_L_DEFAULT` |
| `comment` | `SCE_L_COMMENT`, `SCE_L_COMMENT2` |
| `keyword` | `SCE_L_COMMAND`, `SCE_L_SHORTCMD`, `SCE_L_CMDOPT` |
| `variable_name` | `SCE_L_TAG`, `SCE_L_TAG2` |
| `constant` | `SCE_L_MATH`, `SCE_L_MATH2`, `SCE_L_SPECIAL` |
| `string` | `SCE_L_VERBATIM` |
| `error` | `SCE_L_ERROR` |

### YAML (`yaml`)

| Role | Lexilla styles |
|---|---|
| `default` | `SCE_YAML_DEFAULT` |
| `comment` | `SCE_YAML_COMMENT` |
| `keyword` | `SCE_YAML_KEYWORD` |
| `variable_name` | `SCE_YAML_IDENTIFIER` |
| `number` | `SCE_YAML_NUMBER` |
| `string` | `SCE_YAML_TEXT` |
| `constant` | `SCE_YAML_REFERENCE`, `SCE_YAML_DOCUMENT` |
| `operator` | `SCE_YAML_OPERATOR` |
| `error` | `SCE_YAML_ERROR` |

## Container lexer mappings

The mrbmacs container lexers use the same semantic roles:

| Mode/style | Role |
|---|---|
| compilation default | `default` |
| compilation error | `error` |
| compilation file | `markup_link` |
| compilation line/column | `number` |
| grep default | `default` |
| grep file | `markup_link` |
| grep line | `number` |
| grep matched pattern | `warning` |

## Migration notes

- Python identifiers previously mapped to `color_keyword`; the profile now uses
  `default`.
- C/C++, Go, Bash, Lua, Lisp, Python, R, Rust, and YAML profiles preserve
  numbers and operators as the distinct `number` and `operator` roles.
- Ruby quoted strings, heredocs and standard streams previously mostly
  collapsed to `color_default`; the implemented Ruby profile now exposes their
  Lexilla categories.
- `SCE_POV_BADDIRECTIVE` previously used the misspelled `color_foregrond`; the
  profile now uses `error`.
- HTML embedded-language mappings should eventually be expanded into explicit
  constant-by-constant tables when implemented. The grouped rule above is the
  mapping decision, not an implementation shortcut.
