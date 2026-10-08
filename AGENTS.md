# Working on dots

Tier: 1

## What it is

Personal dotfiles for one Arch Linux machine: Hyprland (Lua config), a
Quickshell desktop shell, and the terminal tools around them. One palette in
`theme/` colours all of it. Nobody else installs this.

## Running it

```
~/.config/theme/apply && hyprctl reload && qs -c shell
```

## Checking it

```
Hyprland --verify-config -c hypr/hyprland.lua && qs -p shell 2>&1 | grep -E 'ERROR|WARN'
```

## Code

[`codestyle.md`](codestyle.md), the same standard at every
tier. This project has more than one module, so the modularity rules apply.

## Rules

1. One config per program. No override layers, no `custom/` directories, no
   `*.bak` files. Colours come only from `theme/palettes`, rendered by
   `theme/apply`.
2. Nothing personal is committed. No keys, no home paths, no dumps. The
   repository ships `*.example` files only.
3. The live configs are copies, never symlinks: the repository moves between
   directories. Code must not assume where the repository is.
4. Packages come from the Arch repositories or the AUR, listed in
   `packages.repo` and `packages.aur`. No installer scripts.
5. Comments are in English only.

## Commits

One step, one commit. A single line of plain English describing what the code
now does. No tool names, no attribution trailers.
