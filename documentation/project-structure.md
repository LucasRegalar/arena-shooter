# Project Structure

## Libraries

- **classic** (https://github.com/rxi/classic) — OOP library for easier class handling in Lua.
- **STI** (https://github.com/karai17/Simple-Tiled-Implementation) — Tiled map loader and renderer for LÖVE. Lives in `lib/sti/`. Handles tileset image loading, SpriteBatch rendering, and tile animations.
- **bump** (https://github.com/kikito/bump.lua) — Lightweight AABB collision detection library. Lives in `lib/bump.lua`. Provides a spatial hash world with `move()` for collision resolution and built-in response types (slide, touch, cross, bounce).

## How the Game Works

A top-down 2D arena shooter built with LÖVE 2D. The player moves around a tile-based map and aims with a crosshair. The map defines the playable area with floor and wall tiles.

## Data Model

### Map

The `Map` class (`classes/map/init.lua`) loads a Tiled-exported Lua map via STI with the Bump plugin and owns both the STI map instance (`self.tiledMap`) and the Bump collision world (`self.bumpWorld`).

Collision geometry is generated automatically by STI's bump plugin from tiles/layers marked `collidable = true` in Tiled. Because STI creates collision rects in native pixel space (16px) while game entities work in scaled coordinates (32px), the Map scales all collision rects by the render scale factor after initialization.

A passability grid (`self.passability`) is also maintained as a 2D boolean table for grid-based queries via `isPassable(x, y)`.

Map configuration constants (native tile size, render scale, grid dimensions) live in `classes/map/config.lua`. The map uses 16x16 pixel tiles rendered at 2x scale (appearing as 32x32 on screen).

### Map Elements (Legacy)

The `classes/map/elements/` directory contains Floor, Wall, and Water classes that were used by the old grid-based map system. These are no longer instantiated — passability is now derived directly from STI tile GIDs. The files remain in the codebase but are unused.

### Player

The player has a position (x, y) in map-space pixel coordinates, a movement speed, a scale value, and an aim target in world space. Input is handled separately in `classes/player/input.lua`, configuration in `classes/player/config.lua`, and all sprite animation / drawing now lives in `classes/ui/playerRenderer.lua`.

### Weapon

The weapon is a world-space entity that stores position and scale only. Its module entrypoint lives at `classes/weapon/init.lua`, while the sprite sheet, quad setup, and draw call live in `classes/ui/weaponRenderer.lua` so rendering stays outside the model layer.

### Game

The `Game` class (`classes/game/init.lua`) is the central model coordinator. It owns the Map, Player, Weapon, and DebugOverlay instances and is responsible for initializing and updating them. It has no rendering logic — all drawing is handled by the renderer layer.

### Renderers

The renderer layer lives in `classes/ui/` and handles all drawing, separate from the game model.

- **GameRenderer** (`classes/ui/gameRenderer.lua`) — top-level renderer orchestrator. Created in `main.lua` with a reference to the `Game` model. Owns all sub-renderers and the map centering offset. Provides `draw()` for world-space rendering and `drawUI()` for screen-space UI.
- **MapRenderer** (`classes/ui/mapRenderer.lua`) — handles all map visuals. Fills a dark background color for the floor area, then delegates tile rendering to the STI map instance at 2x scale. Reads the `Map` model but never modifies it.
- **PlayerRenderer** (`classes/ui/playerRenderer.lua`) — owns the player sprite sheet, animation timer, sprite quads, crosshair rendering, and temporary player debug visuals while reading the `Player` model for world state.
- **WeaponRenderer** (`classes/ui/weaponRenderer.lua`) — owns the weapon sprite sheet and quad data, and reproduces the previous weapon draw call while reading position and scale from the `Weapon` model.

This pattern separates concerns cleanly: model classes (`Game`, `Map`, `MapElement`) have zero `love.graphics` calls, and renderers read model data to produce visuals. When new entities need rendering (player, weapon), they follow the same pattern — a renderer in `classes/ui/` that reads the model.

### DebugOverlay

The `DebugOverlay` class (`classes/ui/debugOverlay.lua`) is a screen-space HUD element that displays diagnostic information (currently player coordinates). It reads the `debug` flag from `gameConfig` and only renders when it is `true`. It is drawn via `GameRenderer:drawUI()`, which is called after the map coordinate transform is popped so the overlay stays fixed on screen.

## Dataflow

1. **Configuration** (`conf.lua`): Love2D runs `love.conf` before creating the window. This sets the window title and fullscreen mode so they are correct from the very first frame.
2. **Initialization** (`love.load`): Pixel filter and window icon are applied. A `Game` instance is created (model), then a `GameRenderer` is created with a reference to the game (view).
3. **Update** (`love.update`): Delegates to `Game:update(dt)` for gameplay state (including STI map tile animations), then `GameRenderer:update(dt)` for presentation-only state such as player animation timing.
4. **Draw** (`love.draw`): Two-phase rendering, handled entirely by `GameRenderer`:
   - **World space**: Applies `love.graphics.translate()` with the renderer's map centering offset, then calls `GameRenderer:draw()` (map via `MapRenderer`, player via `PlayerRenderer`, weapon via `WeaponRenderer`)
   - **Screen space**: After popping the transform, calls `GameRenderer:drawUI()` (debug overlay and future HUD elements)

## Why Things Are Implemented This Way

### Tiled map workflow
Maps are authored in the Tiled editor (https://www.mapeditor.org/) and exported as Lua files into `maps/`. STI loads these exports directly, handling tileset images, tile rendering, and animations. This separates level design tooling from game code and provides a visual editor for map creation.

### Shared coordinate translate
All game objects share a single `love.graphics.translate()` applied in `love.draw()`. This means every object uses map-space coordinates (origin at top-left of the map grid). The centering offset is computed by `GameRenderer` from the map's pixel dimensions. This approach keeps coordinate systems consistent across collision detection and rendering.

### Collision via Bump
The Bump library provides AABB collision detection with a spatial hash grid. STI's bump plugin automatically generates collision rectangles from tiles marked `collidable = true` in Tiled. The collision rects are scaled from native pixel space (16px tiles) to game coordinate space (32px tiles) at initialization. The Bump world is created and exposed by the Map model (`map.bumpWorld`). Wiring player movement through `bumpWorld:move()` is pending a separate refactor.

### Renderer separation
Model classes (`Game`, `Map`, `Player`, `Weapon`) contain gameplay data and logic — they have zero `love.graphics` calls. The `Map` model owns the STI map instance because STI is fundamentally map data that also knows how to render itself. All drawing is handled by renderer classes in `classes/ui/`, with `MapRenderer` calling through to STI's draw method. `PlayerRenderer` and `WeaponRenderer` follow the same pattern for entity visuals so sprite assets, quads, and animation timers stay in the presentation layer.

### Render scale
The Tiled map uses 16x16 pixel tiles, but we render at 2x scale so each tile appears as 32x32 on screen. This keeps the visual size consistent with player and weapon sprites. The scale factor is configured in `classes/map/config.lua` and applied by `MapRenderer` when calling STI's draw method.
