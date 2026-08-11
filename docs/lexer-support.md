# Language and Lexer Support

This document records the relationship between file detection, mrbmacs modes,
`LexerProfile`, and Lexilla lexers.

## Reference version

- Inventory date: 2026-08-12
- Lexilla version: 5.5.2 (`version.txt`: `552`)
- Lexilla version selected by `mruby-scintilla-base`: `lexilla_ver = '552'`
- Registered Lexilla lexer modules: 133

The Lexilla version is independent of the `mruby-scintilla-base` gem version.
The inventory below is based on the lexer modules registered under
`lexilla/lexers` in Lexilla 5.5.2.

## Status definitions

- **Supported / dedicated**: mrbmacs has a mode and `LexerProfile` using a
  dedicated Lexilla lexer.
- **Supported / shared**: mrbmacs has a mode and `LexerProfile`, but shares a
  general-purpose Lexilla lexer with related languages.
- **Extension candidate**: an existing mode/profile can probably support the
  file by adding file detection.
- **Shared-lexer candidate**: a new mode/profile can reuse an existing Lexilla
  lexer, but needs language-specific keywords, properties, or style mapping.
- **Dedicated-lexer candidate**: Lexilla provides a dedicated lexer, but
  mrbmacs does not currently expose it as a mode.
- **No dedicated lexer**: Lexilla 5.5.2 has no lexer module dedicated to that
  language.

Lexer availability alone does not mean that a language is usable in mrbmacs.
A usable language mode also needs file detection, a mode, and an appropriate
`LexerProfile`.

## Currently supported file modes

| Language or format | File detection | mrbmacs mode | LexerProfile | Lexilla lexer | Status | Notes |
|---|---|---|---|---|---|---|
| Ruby | `.rb`, `.rake`, `Rakefile`, `.mrbmacsrc` | `RubyMode` | `RUBY_LEXER_PROFILE` | `ruby` | Supported / dedicated | Includes the mrbmacs configuration file. |
| C/C++ | `.c`, `.h`, `.cpp`, `.cxx` | `CppMode` | `CPP_LEXER_PROFILE` | `cpp` | Supported / dedicated | The `cpp` lexer is also shared by several other modes. |
| Objective-C | `.m`, `.mm` | `ObjectivecMode` | `OBJECTIVEC_LEXER_PROFILE` | `cpp` | Supported / shared | Includes Objective-C keywords and common Foundation types. |
| CSS | `.css` | `CssMode` | `CSS_LEXER_PROFILE` | `css` | Supported / dedicated | |
| Diff | `.diff` | `DiffMode` | `DIFF_LEXER_PROFILE` | `diff` | Supported / dedicated | `.patch` is not currently detected. |
| Java | `.java` | `JavaMode` | `JAVA_LEXER_PROFILE` | `cpp` | Supported / shared | Uses Java-specific keywords and style mapping. |
| JavaScript | `.js` | `JavascriptMode` | `JAVASCRIPT_LEXER_PROFILE` | `cpp` | Supported / shared | JSX is not currently detected. |
| TypeScript | `.ts` | `TypescriptMode` | `TYPESCRIPT_LEXER_PROFILE` | `cpp` | Supported / shared | TSX is not currently detected. |
| JSON | `.json` | `JsonMode` | `JSON_LEXER_PROFILE` | `json` | Supported / dedicated | JSONC/JSON5 behavior requires separate validation. |
| Markdown | `.md` | `MarkdownMode` | `MARKDOWN_LEXER_PROFILE` | `markdown` | Supported / dedicated | |
| Plain text | `.txt`, unmatched files | `FundamentalMode` | `FUNDAMENTAL_LEXER_PROFILE` | `indent` | Supported / dedicated | Also acts as the fallback mode. |
| Haskell | `.hs` | `HaskellMode` | `HASKELL_LEXER_PROFILE` | `haskell` | Supported / dedicated | Literate Haskell has a separate Lexilla lexer and is not detected. |
| HTML/ERB | `.html`, `.htm`, `.erb` | `HtmlMode` | `HTML_LEXER_PROFILE` | `hypertext` | Supported / dedicated | |
| Lisp | `.lisp` | `LispMode` | `LISP_LEXER_PROFILE` | `lisp` | Supported / dedicated | |
| Lua | `.lua` | `LuaMode` | `LUA_LEXER_PROFILE` | `lua` | Supported / dedicated | |
| Bash | `.sh` | `BashMode` | `BASH_LEXER_PROFILE` | `bash` | Supported / dedicated | `.bash` and `.zsh` are not currently detected. |
| Go | `.go` | `GoMode` | `GO_LEXER_PROFILE` | `cpp` | Supported / shared | Uses Go-specific keywords and style mapping. |
| Perl | `.pl` | `PerlMode` | `PERL_LEXER_PROFILE` | `perl` | Supported / dedicated | |
| POV-Ray | `.pov` | `PovMode` | `POV_LEXER_PROFILE` | `pov` | Supported / dedicated | |
| Python | `.py` | `PythonMode` | `PYTHON_LEXER_PROFILE` | `python` | Supported / dedicated | |
| R | `.r` | `RMode` | `R_LEXER_PROFILE` | `r` | Supported / dedicated | |
| Rust | `.rs` | `RustMode` | `RUST_LEXER_PROFILE` | `rust` | Supported / dedicated | |
| LaTeX | `.tex` | `LatexMode` | `TEX_LEXER_PROFILE` | `latex` | Supported / dedicated | Lexilla also provides the separate `tex` lexer. |
| XML | `.xml`, `.plist` | `XmlMode` | `XML_LEXER_PROFILE` | `xml` | Supported / dedicated | |
| YAML | `.yml`, `.yaml` | `YamlMode` | `YAML_LEXER_PROFILE` | `yaml` | Supported / dedicated | |
| Makefile | `Makefile`, `makefile` | `MakeMode` | `MAKE_LEXER_PROFILE` | `makefile` | Supported / dedicated | Detected by basename rather than extension. |

## Internal and special buffers

| Buffer | mrbmacs mode | LexerProfile | Lexer | Notes |
|---|---|---|---|---|
| `*scratch*` | `IrbMode` | Ruby profile | `ruby` | Interactive Ruby buffer. |
| `*compilation*` | `CompilationMode` | Application-defined profile | none | Uses container/application styling. |
| `*grep*` | `GrepMode` | Application-defined profile | none | Uses container/application styling. |
| `*preview_theme*` | Theme preview mode | none | none | Applies preview styles directly. |
| `*Messages*` | `FundamentalMode` | Fundamental profile | `indent` | |

## Practical support candidates

These are gaps likely to matter in this repository or common development
workflows. Their presence here is not a decision to implement them.

| Language or format | Typical files | Lexilla lexer | Candidate status | Required mrbmacs work |
|---|---|---|---|---|
| TSX | `.tsx` | `cpp` | No dedicated lexer / shared-lexer candidate | Requires TypeScript plus JSX-aware properties and validation. |
| C# | `.cs` | `cpp` | No dedicated lexer / shared-lexer candidate | Add C# keywords, properties, and style mapping. |
| JSX | `.jsx` | `cpp` | Shared-lexer candidate | Extend or specialize the JavaScript mode after validating JSX behavior. |
| Patch | `.patch` | `diff` | Extension candidate | Add `.patch` detection to `DiffMode`. |
| Bash/Zsh scripts | `.bash`, `.zsh` | `bash` | Extension candidate | Add extensions after confirming whether both should use `BashMode`. |
| TOML | `.toml` | `toml` | Dedicated-lexer candidate | Add a mode, profile, and file detection. |
| CMake | `CMakeLists.txt`, `.cmake` | `cmake` | Dedicated-lexer candidate | Add basename/extension detection, a mode, and a profile. |
| SQL | `.sql` | `sql` | Dedicated-lexer candidate | Add a mode/profile; keyword dialect policy must be selected. |
| Assembly | `.s`, `.asm` | `asm` | Dedicated-lexer candidate | Add a mode/profile and decide which assembler dialects to cover. |
| PowerShell | `.ps1`, `.psm1` | `powershell` | Dedicated-lexer candidate | Add a mode, profile, and file detection. |
| INI/properties | `.ini`, `.properties` | `props` | Dedicated-lexer candidate | Add a format-oriented mode/profile and file detection. |
| JSON with comments / JSON5 | `.jsonc`, `.json5` | `json` | Shared-profile candidate | Validate lexer properties and syntax differences before adding detection. |

## Lexilla 5.5.2 modules not exposed as mrbmacs language modes

After excluding the lexers used by the supported modes and the internal
`null`, `errorlist`, and `escseq` modules, 110 registered lexer modules are not
currently exposed as mrbmacs language modes:

```text
a68k, abaqus, abl, ada, apdl, as, asciidoc, asm, asn1, asy, au3, ave, avs,
baan, batch, bib, blitzbasic, bullant, caml, cil, clarion, clarionnocase,
cmake, COBOL, coffeescript, conf, cppnocase, csound, d, dart, dataflex, DMAP,
DMIS, edifact, eiffel, eiffelkw, escript, f77, fcST, flagship, forth, fortran,
freebasic, fsharp, gdscript, gui4cli, hollywood, ihex, inno, julia, kix, kvirc,
literatehaskell, lot, lout, matlab, maxima, metapost, mmixal, modula, mssql,
mysql, nim, nimrod, nix, nncrontab, nsis, octave, opal, oscript, pascal,
phpscript, PL/M, po, powerbasic, powerpro, powershell, props, ps, purebasic,
raku, rebol, sas, scriptol, sinex, smalltalk, SML, sorcins, specman, spice,
sql, srec, stata, TACL, tads3, TAL, tcl, tcmd, tehex, tex, toml, troff,
txt2tags, vb, vbscript, verilog, vhdl, visualprolog, x12, zig
```

Some module names represent lexer variants or dialects rather than distinct
languages. Conversely, languages such as Objective-C, TypeScript, and C# do
not appear in this list because they use, or can use, the `cpp` lexer rather
than dedicated lexer modules in Lexilla 5.5.2.

## Updating this inventory

When the Lexilla version changes:

1. Update the version and inventory date above.
2. Re-enumerate `LexerModule` registrations under `lexilla/lexers`.
3. Compare them with the profiles under `mrblib/lexer_profiles`.
4. Compare file detection and mode selection in `mrblib/mode_manager.rb`.
5. Recheck shared-lexer languages separately; module-name comparison alone
   cannot identify them.
