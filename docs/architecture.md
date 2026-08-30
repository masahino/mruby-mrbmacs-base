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
| `Application` | `app.rb` (+ many reopens) | lifecycle, argument parsing, config, keymap dispatch, commands, the notification event table, `run` |
| `FrameBase` | `frame.rb` | the set of edit windows, theme application, mode-line string, window switch / split / enlarge, `echo_*` (minibuffer) contract |
| `EditWindow` | `window.rb` | one Scintilla view + its buffer: margins, markers, theme styling, mode settings |

Most feature code is added to `Application` by **reopening** it from many
files (`basic.rb`, `fileio.rb`, `buffer.rb`, `command.rb`, `completion.rb`,
`event.rb`, `sci_event.rb`, `app_keybind.rb`, …). Commands are instance
methods on `Application` or on the `Command` module mixed into it.

`app.rb#run` calls `editloop`, which is **not defined in base** — each
frontend provides it (or, for callback-driven toolkits, does not: the toolkit
owns the loop).

### Intermediate classes

- `ApplicationTerminal < Application` (`app_terminal.rb`) — behaviour common
  to the two terminal frontends: blocking incremental search, blocking
  query-replace, clipboard via `pbcopy`/`pbpaste`/`clip.exe`.
- `Frame < FrameBase` (`frame.rb`) — currently an empty class. The two
  terminal frontends and GTK reopen `Mrbmacs::Frame`; Cocoa subclasses
  `FrameBase` directly. Treat `Frame` as "the frame terminal frontends
  extend", not as shared logic.

### Frontend classes

| Frontend | Application class | Frame | EditWindow |
| --- | --- | --- | --- |
| cocoa | `ApplicationCocoa < Application` | `FrameCocoa < FrameBase` | `PaneCocoa < EditWindow` |
| gtk | `ApplicationGtk < Application` | reopens `Frame` | reopens base window |
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
| lifecycle, args, config, recent keys | `app.rb` | — |
| keymap definition | `keymap.rb`, `app_keybind.rb` | `set_keybind` re-implemented in `application_cocoa.rb` (`C-` maps to Command, not Control) |
| commands (movement, file, buffer, comment, macro, …) | `basic.rb`, `fileio.rb`, `buffer.rb`, … | small GTK overrides (`*-gtk.rb`, 1–51 lines) |
| notification dispatch (`add_sci_event`, `call_sci_event`) | `event.rb`, `sci_event.rb` | delivery mechanism differs (queue vs synchronous), dispatch table is shared |
| theme / style system | `theme*.rb`, `style_*.rb`, `window.rb` | — (see `style-system-design.md`) |
| mode / lexer profiles | `mode*.rb`, `lexer_profile*.rb` | — |
| mode-line string | `FrameBase#get_mode_str` | mode-line *placement* forked (`modeline` in every frontend Frame) |
| window split / enlarge | `app_window.rb`, `FrameBase` (terminal) | Cocoa overrides for `NSSplitView` |
| minibuffer (`echo_gets`, `echo_set_prompt`, `echo_puts`, `complete_echo_input`, `select_buffer`, `y_or_n`) | contract only (`FrameBase`, all `NotImplementedError`) | full re-implementation in `echo_win_termbox.rb`, `frame_curses.rb`, `frame_cocoa.rb`, `frame-gtk.rb` (GTK mirrors Cocoa: `SC_MARGIN_TEXT` prompt + nested `gtk_main` in `mrbmacs-echo.c`) |
| incremental search | — | `app_terminal.rb#isearch` (blocking), `search_cocoa.rb` (events), gtk `find.rb` (events) |
| query-replace | — | `app_terminal.rb` (blocking), `replace_cocoa.rb` (events), gtk `replace.rb` (events) |
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
  path is gone). Still open: `find.rb` and `replace.rb` disagree on whether
  to reopen `Application` or `ApplicationGtk`, and gtk `replace.rb` expects a
  tri-state `y_or_n` (`true` / `false` / `nil`) while the echo-area `y_or_n`
  returns only a boolean (C-g == "no").

## Known duplication (candidates for consolidation)

Recorded here so the analysis is not repeated. None of these are scheduled.

1. **Iterative search / replace primitive.** The "search target, wrap,
   select" step and the "find next match, replace, advance" step are
   frontend-independent but written three times (terminal / cocoa / gtk) with
   different structure. Extracting them to `Application` would leave only the
   blocking-loop vs state-machine shell per frontend.
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
