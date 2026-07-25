# Version Control Internals

## Responsibilities

Version-control support is divided into:

- repository discovery;
- repository status and branch information;
- file diff generation;
- diff-hunk parsing;
- gutter marker generation;
- editor command integration.

The core implementation is independent of the graphical or terminal frontend.

## `VC` class

`Mrbmacs::VC` is responsible for:

- detecting a Git working tree;
- finding the repository root;
- determining the current branch;
- running file-specific Git commands;
- parsing zero-context unified diffs.

## Git commands

Repository discovery uses:

```text
git rev-parse --show-toplevel
git symbolic-ref --quiet --short HEAD
git rev-parse --short HEAD
```

File changes use:

```text
git diff --no-ext-diff --unified=0 HEAD -- FILE
```

## Diff-hunk classification

A unified diff hunk is classified as:

- `added` when the old-line count is zero;
- `deleted` when the new-line count is zero;
- `modified` otherwise.

Added and modified markers are assigned to every affected line in the new
file.

A deleted hunk is assigned to the nearest remaining line because the deleted
lines have no corresponding line in the current document.

## Scintilla margins

The common margin layout is:

| Margin | Purpose |
| --- | --- |
| 0 | Line numbers, debugger markers, and change history |
| 1 | Folding |
| 2 | Version-control indicators |

The VC margin has width 1 and uses `SC_MARGIN_SYMBOL`.

## Marker allocation

| Marker | Purpose |
| --- | --- |
| `MARKERN_BREAKPOINT` | DAP breakpoint |
| `MARKERN_CURRENT` | Current DAP position |
| `MARKERN_VC_ADDED` | Added line |
| `MARKERN_VC_MODIFIED` | Modified line |
| `MARKERN_VC_DELETED` | Deleted position |

VC markers use `SC_MARK_LEFTRECT`.

## Refresh lifecycle

`vc_refresh_gutter`:

1. removes all existing VC markers;
2. ignores buffers not visiting a file;
3. ignores files outside a managed repository;
4. obtains changes relative to `HEAD`;
5. converts hunks to marker positions;
6. adds the corresponding Scintilla markers.

It is called after `find_file` and `save_buffer`, and is also exposed as an
interactive command.

## Frontend responsibilities

Frontend implementations configure the line-number margin mask. VC margin
configuration remains in the shared base implementation.

The following frontends must preserve the common marker mask:

- `mruby-bin-mrbmacs-termbox`;
- `mruby-bin-mrbmacs-curses`;
- `mruby-bin-mrbmacs-gtk`.

## Testing

Tests cover:

- repository discovery;
- branch and detached-`HEAD` representation;
- diff-hunk parsing;
- marker-line conversion;
- gutter refresh and marker replacement;
- margin type, width, and mask.
