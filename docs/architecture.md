# Architecture: base and frontends

## Purpose

`mruby-mrbmacs-base` holds the editor logic that does not depend on a
particular UI toolkit. Each `mruby-bin-mrbmacs-*` gem is a *frontend*: it
supplies the toolkit binding, the main event loop, and the toolkit-specific
parts of window layout, rendering and input.

This document records what is shared, what is per-frontend, and **why**, so
that the split does not have to be re-derived when planning a change.

## Repository layout

| Gem | Role |
| --- | --- |
| `mruby-mrbmacs-base` | toolkit-independent editor logic |
| `mruby-mrbmacs-lsp`, `mruby-mrbmacs-dap`, `mruby-mrbmacs-themes-*` | optional feature gems, toolkit-independent |
| `mruby-scintilla-base` + `mruby-scintilla-{cocoa,gtk,curses,termbox}` | Scintilla bindings, one per toolkit |
| `mruby-bin-mrbmacs-cocoa` | macOS / AppKit frontend |
| `mruby-bin-mrbmacs-gtk` | GTK frontend (partial / work in progress) |
| `mruby-bin-mrbmacs-curses` | terminal frontend, curses binding |
| `mruby-bin-mrbmacs-termbox` | terminal frontend, termbox binding |

All `mrblib/*.rb` in a gem are loaded automatically in alphabetical order.
There are no explicit `require`s between mrblib files, so file renames and
splits only need to respect load order.

## The three base tiers

Editor state is organised into three classes, all in `mruby-mrbmacs-base`:

| Class | File | Owns |
| --- | --- | --- |
| `Application` | `10_app.rb` (+ many reopens) | lifecycle, argument parsing, config, keymap dispatch, commands, the notification event table, `run` |
| `FrameBase` | `frame.rb` | the set of edit windows, theme application, mode-line string, window switch / split / enlarge, `echo_*` (minibuffer) contract |
| `EditWindow` | `window.rb` | one Scintilla view + its buffer: margins, markers, theme styling, mode settings |

Most feature code is added to `Application` by **reopening** it from many
files (`basic.rb`, `fileio.rb`, `buffer.rb`, `20_command.rb`, `completion.rb`,
`event.rb`, `sci_event.rb`, `app_keybind.rb`, …). Commands are instance
methods on `Application` or on the `Command` module mixed into it.

`10_app.rb#run` calls `editloop`, which is **not defined in base** — each
frontend provides it (or, for callback-driven toolkits, does not: the toolkit
owns the loop).

### Intermediate classes

- `ApplicationTerminal < Application` (`app_terminal.rb`) — behaviour common
  to the two terminal frontends: blocking incremental search, blocking
  query-replace, clipboard via `pbcopy`/`pbpaste`/`clip.exe`.
- `ApplicationGui < Application` (`app_gui.rb`, `search_gui.rb`,
  `replace_gui.rb`) — behaviour common to the two callback-driven frontends:
  event-driven incremental search and query-replace through the echo-area
  minibuffer (`echo_key_press`, `perform_isearch`, `query_replace_key_press`,
  …), and the isearch/replace instance variables. Parallel to
  `ApplicationTerminal`; the two intermediate classes never meet.
- `Frame < FrameBase` (`frame.rb`) — currently an empty class. The two
  terminal frontends and GTK reopen `Mrbmacs::Frame`; Cocoa subclasses
  `FrameBase` directly. Treat `Frame` as "the frame terminal frontends
  extend", not as shared logic.

### Frontend classes

| Frontend | Application class | Frame | EditWindow |
| --- | --- | --- | --- |
| cocoa | `ApplicationCocoa < ApplicationGui` | `FrameCocoa < FrameBase` | `PaneCocoa < EditWindow` |
| gtk | `ApplicationGtk < ApplicationGui` | reopens `Frame` | reopens base window |
| curses | `ApplicationCurses < ApplicationTerminal` | reopens `Frame` | reopens `EditWindow` |
| termbox | `ApplicationTermbox < ApplicationTerminal` | reopens `Frame` | `EditWindowTermbox < EditWindow` |

## Why frontends diverge

Four axes account for almost all per-frontend code.

### 1. Who owns the main loop

- **Terminal (curses, termbox):** the frontend owns the loop.
  `editloop` is an explicit `loop do … IO.select … end`. Scintilla
  notifications are pushed onto `@frame.sci_notifications` and drained once
  per iteration.
- **Callback (cocoa, gtk):** the toolkit owns the loop (`[NSApp run]`,
  `Gtk.main`). There is no `editloop`. Key events arrive as callbacks
  (`key_press`, `echo_key_press`); Scintilla notifications are delivered
  synchronously to `sci_notify`.

Consequence: anything that "reads input in a loop" (incremental search,
query-replace prompts, `y_or_n`, `echo_gets`) must be a **blocking loop** in
terminal frontends and an **event-driven state machine** in callback
frontends. This is the single largest source of forked code.

### 2. Window layout model

- **Terminal:** edit windows are rectangles addressed by `x1,y1,x2,y2`
  character cells. `split_window`, `enlarge_window`, etc. are coordinate
  arithmetic (`app_window.rb`, `FrameBase#enlarge_window`).
- **Cocoa:** layout is a tree of native `NSSplitView`s (`SplitCocoa`,
  `TabCocoa`); `FrameCocoa` overrides `switch_window` / `delete_window` /
  `enlarge_window*` to manipulate native views.

### 3. Rendering model

- **Terminal:** Scintilla renders to a character grid; a full `refresh` is
  cheap and is called liberally.
- **Cocoa / gtk:** Scintilla renders through the native compositor
  asynchronously; partial invalidation matters, and code cannot assume a
  synchronous full redraw after every change.

### 4. Toolkit services

Clipboard, font selection, file dialogs, the menu bar, IME, and DPI handling
are toolkit APIs and live in the frontend (often with a small native `.c`
helper under `tools/`).

## Subsystem sharing matrix

| Subsystem | Shared (base) | Forked, and why |
| --- | --- | --- |
| lifecycle, args, config, recent keys | `10_app.rb` | — |
| keymap definition | `keymap.rb`, `app_keybind.rb` | `set_keybind` re-implemented in `application_cocoa.rb` (`C-` maps to Command, not Control) |
| commands (movement, file, buffer, comment, macro, …) | `basic.rb`, `fileio.rb`, `buffer.rb`, … | small GTK overrides (`*-gtk.rb`, 1–51 lines) |
| notification dispatch (`add_sci_event`, `call_sci_event`) | `event.rb`, `sci_event.rb` | delivery mechanism differs (queue vs synchronous), dispatch table is shared |
| theme / style system | `theme*.rb`, `style_*.rb`, `window.rb` | — (see `style-system-design.md`) |
| mode / lexer profiles | `mode*.rb`, `lexer_profile*.rb` | — |
| mode-line string | `FrameBase#get_mode_str` | mode-line *placement* forked (`modeline` in every frontend Frame) |
| window split / enlarge | `app_window.rb`, `FrameBase` (terminal) | Cocoa overrides for `NSSplitView` |
| minibuffer (`echo_gets`, `echo_set_prompt`, `echo_puts`, `complete_echo_input`, `select_buffer`, `y_or_n`) | contract only (`FrameBase`, all `NotImplementedError`) | full re-implementation in `echo_win_termbox.rb`, `frame_curses.rb`, `frame_cocoa.rb`, `frame-gtk.rb` (GTK mirrors Cocoa: `SC_MARGIN_TEXT` prompt + nested `gtk_main` in `mrbmacs-echo.c`) |
| incremental search | `search_gui.rb` (`ApplicationGui`, event-driven, shared by cocoa+gtk) | `app_terminal.rb#isearch` (blocking loop, terminal only) |
| query-replace | `replace_gui.rb` (`ApplicationGui`, event-driven, shared by cocoa+gtk) | `app_terminal.rb` (blocking loop, terminal only) |
| clipboard | — | `app_terminal.rb` (shell out), Cocoa/GTK use toolkit |

## Naming and structure caveats

- **`app_window.rb`** — despite the name, this is terminal coordinate-based
  window management (it reopens `Application` and `Command`). Cocoa overrides
  it. It is not "GUI window" code.
- **`app_terminal.rb`** — mixes two unrelated concerns: incremental
  search / query-replace, and kill / yank / clipboard.
- **`Frame`** — empty `class Frame < FrameBase`. Not a logic tier.
- **`class Application` reopens** are spread across ~15 files. There is no
  single place that lists the full method surface.
- **GTK** minibuffer input now works (echo-area, mirroring Cocoa), including
  file/directory prompts: `read_file_name` / `read_dir_name` /
  `read_save_file_name` and `find_file` are no longer overridden — GTK uses
  the base `echo_gets` versions like every other frontend (the GtkFileChooser
  path is gone). GTK's incremental search and query-replace also moved off
  the old `find.rb`/`replace.rb` (deleted) and onto the same non-modal
  echo-area state machine as Cocoa, now shared as `ApplicationGui` in base;
  only the raw-keyval-to-key-string translation stays GTK-specific
  (`echo_key_gtk.rb`).

## Known duplication (candidates for consolidation)

Recorded here so the analysis is not repeated. None of these are scheduled.

1. **Iterative search / replace primitive.** ~~The "search target, wrap,
   select" step and the "find next match, replace, advance" step are
   frontend-independent but written three times.~~ Resolved for cocoa/gtk:
   both now share `search_gui.rb`/`replace_gui.rb` via `ApplicationGui`.
   `app_terminal.rb`'s blocking-loop version is still separate, since its
   control flow (a `loop do … waitkey … end`) has no event-driven
   counterpart to share with; extracting the frontend-independent "search
   target, wrap, select" step out of both shapes remains a candidate (see
   `ApplicationGui#perform_isearch` vs `ApplicationTerminal#isearch`).
2. **`complete_echo_input`** (candidate split, `common_prefix`, insert
   suffix, `sci_autoc_show`) is duplicated in `frame_cocoa.rb`,
   `frame-gtk.rb`, and `echo_win_termbox.rb`.
3. **`echo_gets` loop skeleton** — could live in `FrameBase` if every
   frontend exposed a normalised `wait_echo_event` seam (Cocoa and GTK
   already do; terminal frontends inline key matching).
4. **`select_buffer`** prefix-filter logic exists in four frontend Frames
   (`frame_cocoa.rb` and `frame-gtk.rb` are now identical).
5. **`set_keybind`** differs between `keymap.rb` and `application_cocoa.rb`
   only in the modifier mapping.
6. **`Mrbmacs.dir_glob`** (`fileio.rb`) is now dead — superseded by
   `Application#path_completions`, referenced only by its own tests.
