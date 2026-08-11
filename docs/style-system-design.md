# Syntax style system design

## Status

Incremental implementation in progress. The semantic style data model,
resolver, user style overrides, and 26 lexer profiles are implemented.
Lexilla and application-provided container lexers use the same profile and
resolver path. Preview Theme lists resolved semantic syntax roles and direct
theme UI settings without depending on a lexer profile. The mappings are in
[`style-mapping.md`](style-mapping.md).

Implemented for Ruby, Python, Bash, C/C++, CSS, Diff, Go, Haskell, Java,
JavaScript, HTML, XML, JSON, Lisp, Lua, Makefile, Markdown, Perl, POV-Ray, R,
Rust, LaTeX, and YAML:

- lexer selection;
- lexer properties;
- all keyword sets;
- Scintilla style to semantic-role mapping;
- theme resolution and user style overrides.

The full theme/UI split and the individually reviewed remaining profiles are
not implemented yet.

## Goals

- Preserve the character of Base16, Solarized, and future themes.
- Use syntax distinctions already produced by Lexilla.
- Keep language definitions independent from concrete colours.
- Allow user overrides by semantic role, language, and Scintilla style.
- Apply the same rules in Curses, Termbox, GTK, and Cocoa.
- Keep frontend-specific code limited to display capability conversion.
- Prevent stale styles after theme, mode, buffer, or pane changes.

## Non-goals

- Replacing Lexilla or changing its lexers.
- Implementing TextMate grammar parsing.
- Giving every Lexilla style a unique colour.
- Changing indentation, completion, syntax checking, or key bindings.
- Adding a new theme in the first implementation step.

## Legacy model

```text
Lexilla style number
  -> Mode#@style (:color_comment, etc.)
  -> Theme#font_color [foreground, background, italic, bold]
  -> sci_style_set_* calls
```

This contains a useful semantic layer, but responsibilities are mixed:

- `Theme#font_color` contains syntax, editor UI, annotation, marker, and mode
  line colours.
- `Mode` contains editing behaviour, lexer selection, keywords, properties, and
  the complete style map.
- Style values are positional arrays and cannot be partially overridden safely.
- `apply_theme`, `set_style`, and `apply_mode_settings` are separate paths.
- Some mode-specific `set_style` methods are not called on the normal path.
- Curses palette conversion mutates Base16 class variables.
- User override precedence is undefined.

## Target model

```text
                    +----------------+
Lexilla style ----> | LexerProfile   |
                    | style -> role  |
                    +-------+--------+
                            |
                            v
                    +----------------+
Theme palette ----> | StyleResolver  | <---- user overrides
Theme role styles ->|                |
                    +-------+--------+
                            |
                            v
                    resolved StyleSpec
                            |
                            v
                    frontend adapter
                            |
                            v
                         Scintilla
```

### Semantic role

A semantic role is a language-independent name such as `comment`, `keyword`,
`type`, `number`, or `diff_added`. The canonical role set is defined in the
mapping document. It should remain much smaller than the set of Lexilla styles.

### StyleSpec

`StyleSpec` replaces positional arrays with named, independently inheritable
properties.

```ruby
StyleSpec.new(
  foreground: :base03,
  background: :editor_background,
  italic: true,
  bold: false
)
```

`nil` means unspecified and inherits from the lower-precedence value. Thus a
user can disable comment italics without replacing the theme foreground.

### Theme

A theme has three sections:

```text
palette  raw named colours
syntax   semantic role -> StyleSpec
ui       editor and application UI role -> StyleSpec or colour
```

Syntax roles include `comment`, `keyword`, and `string`. UI roles include
background, selection, line number, caret line, mode line, annotations, and
markers.

Base16 themes should provide `base00` through `base0F` plus optional overrides.
A shared Base16 definition maps semantic roles to that palette. Solarized dark
and light should likewise share semantic mappings while choosing different
monotone foregrounds and backgrounds.

### LexerProfile

A lexer profile contains Scintilla/Lexilla integration data only:

```ruby
LexerProfile.new(
  :ruby,
  'ruby',
  {
    Scintilla::SCE_RB_COMMENTLINE => :comment,
    Scintilla::SCE_RB_NUMBER => :number
  },
  { 0 => RUBY_KEYWORDS },
  { 'fold' => '1' }
)
```

Modes retain editing behaviour such as indentation, comment syntax, completion,
syntax checking, commands, and key bindings. Compilation and grep container
lexers use the same profile interface.

The profile is the source of truth for lexer configuration and style states:

```text
LexerProfile
  lexer          Lexilla lexer name, or nil for a container lexer
  styles         Scintilla style number -> semantic role
  keyword_sets   Lexilla word-list index -> words
  properties     Lexilla/Scintilla property name -> value
```

This distinction is important because an mrbmacs mode name and a Lexilla lexer
name are not always the same. For example, Go, Objective-C, and TypeScript
modes use the `cpp` lexer. Compilation and grep use a `nil` lexer name: their Modes respond to
`SCN_STYLENEEDED` and assign the profile's style numbers themselves.

Completion remains a Mode responsibility. A Mode may use profile keyword set 0
as its default completion source and add non-keyword candidates separately.
The first Ruby migration preserves the previous combined keyword list to avoid
changing completion and highlighting at the same time.

### StyleResolver

The resolver is the only component that knows override precedence. Proposed
precedence, lowest to highest:

1. Built-in fallback.
2. Theme semantic-role style.
3. Theme language-specific override.
4. User global semantic-role override.
5. User language-specific semantic-role override.
6. User exact Scintilla-style override.

Properties merge independently. Example configuration shape:

```ruby
config.styles.override(:comment, italic: false)
config.styles.override(:string, lexer: :ruby, foreground: :base0C)
config.styles.override_scintilla(
  :ruby,
  Scintilla::SCE_RB_SYMBOL,
  bold: true
)
```

The current public methods have been validated under the project's supported
mruby build. Further API changes should remain backward-compatible during the
incremental migration.

## Application order

Theme selection, buffer selection, mode changes, and new panes must all use the
same path:

1. Select and configure the lexer.
2. Apply keywords and lexer properties.
3. Set `STYLE_DEFAULT`, including font properties.
4. Call `STYLECLEARALL` once.
5. Resolve and apply lexer styles.
6. Apply line-number, brace, indentation, and other Scintilla UI styles.
7. Apply selection, caret, markers, annotations, echo area, and mode line.
8. Refresh affected views.

This order prevents `STYLECLEARALL` from erasing later settings and prevents
styles from a previous lexer remaining after a mode change.

## Frontend boundary

The base layer owns mapping, resolution, precedence, and application order.
Frontends handle only representation limits.

### GTK and Cocoa

- Use resolved Scintilla colours directly.
- Apply native mode-line and echo-area colours from UI roles.
- Retain native font selection and focus rendering.

### Termbox

- Convert resolved Scintilla colours to Termbox RGB.
- Use deterministic fallbacks for unsupported attributes.
- Render mode lines from resolved UI roles.

### Curses

- Convert resolved colours to the available colour model.
- Allocate or reuse colour pairs.
- Reprogram the terminal palette only when supported.
- Never mutate theme definitions.
- Define deterministic 8-, 16-, and 256-colour fallbacks.

## Compatibility

The implementation adapts existing `Theme#font_color` arrays to `StyleSpec`:

```text
[foreground, background, italic, bold]
  -> legacy adapter
  -> StyleSpec
```

This keeps personal configuration working after mode style mappings have moved
to `LexerProfile`. Existing roles initially reproduce existing colours. Visible
improvements come from the reviewed mapping, not unrelated palette changes.

## Implementation stages

### Stage 1: data model, no visual change

Status: implemented.

- Add `StyleSpec`, merging, and tests.
- Adapt current `font_color` arrays.
- Add a resolver that reproduces current output.
- Keep all current mode mappings.

Acceptance: queried Scintilla style properties match the current implementation.

### Stage 2: Ruby profile

Status: implemented, including lexer name, keyword set 0, and the `fold`
property. Ruby Mode no longer contains its legacy lexer, keyword, or style map.

- Introduce one `LexerProfile` for Ruby.
- Route Ruby through the resolver.
- Keep other modes on the compatibility adapter.
- Verify all four frontends.

Acceptance: theme switching and user overrides work without affecting other
modes.

### Stage 3: reviewed mappings

Status: implemented for Ruby, Python, Bash, C/C++, CSS, Diff, Go, Haskell,
Java, JavaScript, Objective-C, TypeScript, HTML, XML, JSON, Lisp, Lua, Makefile,
Markdown, Perl, POV-Ray, R, Rust, LaTeX, and YAML.

Java, JavaScript, Objective-C, and TypeScript use independent profiles over
Lexilla's `cpp` lexer. `CLikeMode` shares only brace-based editing behaviour
among C++, Go, Java, JavaScript, Objective-C, and TypeScript; keywords,
properties, and style refinements remain in each `LexerProfile`.

- Apply the reviewed Ruby mapping.
- Add C/C++, Python, Markdown, and Diff profiles.
- Compare representative source files before and after.

Acceptance: useful Lexilla distinctions become visible in Base16 and Solarized
dark/light without reducing readability.

### Stage 4: remaining modes and frontend cleanup

Status: Compilation and Grep container profiles, the Fundamental indent
profile, and the semantic Preview Theme profile are implemented. Legacy mode
lexer, keyword, and style fallbacks have been removed. Frontend colour
capability cleanup remains.

- Remove frontend theme-mapping duplication.
- Replace Curses theme mutation with capability conversion.

### Stage 5: optional formats and themes

- Add Dracula using its semantic specification.
- Evaluate a limited TextMate token-scope importer.
- Connect future LSP semantic tokens to the same semantic roles.

These are separate enhancements, not requirements for the core refactoring.

## Validation

### Unit tests

- Role resolution and partial `StyleSpec` merges.
- Override precedence.
- Unknown role and style fallback.
- Base16 and Solarized mappings.
- Mode/theme switching without stale styles.
- Legacy configuration compatibility.

### Mapping tests

- Every mapped constant exists in the selected Scintilla version.
- Every mapping refers to a known semantic role.
- Duplicate assignments in one profile are rejected.
- Boundary constants such as `SCE_RB_UPPER_BOUND` are not applied as styles.

### Visual tests

Use fixed Ruby, C++, Python, Markdown, Diff, HTML-with-embedded-language, and
YAML samples. Compare Base16 and Solarized dark/light. Check numbers, operators,
heredocs, markup, embedded languages, errors, and diff states.

Fixed samples for every implemented profile are stored in
[`examples/style-preview`](../examples/style-preview/). Each filename is
recognized by `ModeManager`, so it can be opened directly in any frontend.
The samples deliberately cover the major mapped lexer styles; some end with
invalid or unterminated syntax so that lexer error roles can also be inspected.

### Cross-frontend tests

- Semantic roles resolve to identical source colours before conversion.
- Curses degradation is deterministic at each supported colour depth.
- Termbox conversion preserves colour channel order.
- GTK and Cocoa retain font, selection, caret, mode-line, and echo-area styles.

## File ownership

Most code belongs in `mruby-mrbmacs-base`:

```text
mrblib/style_spec.rb
mrblib/style_resolver.rb
mrblib/lexer_profile.rb
mrblib/lexer_profiles/*.rb
mrblib/theme.rb
mrblib/theme/*.rb
mrblib/mode.rb
mrblib/config.rb
mrblib/app_window.rb
mrblib/window.rb
```

Frontend changes should be limited to colour/attribute capability adapters and
native UI application.

## Decisions

- Use unprefixed semantic role names with legacy `color_` aliases.
- Defer theme-specific lexer overrides.
- Degrade unsupported frontend attributes deterministically.
- Retain theme subclasses during incremental migration.
- Store mappings in dedicated `mrblib/lexer_profiles/*.rb` files.
- Put lexer names, styles, keyword sets, and lexer properties in
  `LexerProfile`.
- Keep indentation, comments, completion behaviour, syntax checking, commands,
  and key bindings in `Mode`.
