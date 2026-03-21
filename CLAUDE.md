# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Top-down 2D arena shooter built with **LÖVE 2D** (Love2D) framework in **Lua**. Early development stage with core player movement, animation, and aiming mechanics.

## Running the Game

```bash
love .
```

No build step required — LÖVE interprets Lua at runtime. Requires the LÖVE runtime installed.

VS Code launch config is available in `.vscode/launch.json`.

## Architecture

**Entry point**: `main.lua` — sets up LÖVE callbacks (`love.load`, `love.update`, `love.draw`), creates Player and Weapon instances.

**Player class** (`classes/player/`):
- `init.lua` — Main class: position, movement, animation, drawing, aim/crosshair
- `input.lua` — Keyboard (O/U/I/8 keys) and gamepad input, returns normalized movement vector
- `config.lua` — All player constants (speed, sprite dimensions, deadzone, crosshair params)
- `animation.lua`, `render.lua` — Placeholder files for future extraction

**Weapon class** (`classes/weapon.lua`): Simple weapon sprite rendering via LÖVE Quads.

**Sprites** (`sprites/`): NuclearLeak character pack (20x20 pixel sprites, 12 color variants) and weapon assets.

## Code Conventions

- **OOP pattern**: Table-based with `__index` metatables (no external class library)
- **Module loading**: `require()` — player submodules are loaded and merged into the Player table
- **Graphics**: Nearest-neighbor filtering (`love.graphics.setDefaultFilter("nearest", "nearest")`) for pixel-perfect rendering
- **Input**: Dual input support (keyboard + gamepad) with deadzone handling and diagonal normalization
