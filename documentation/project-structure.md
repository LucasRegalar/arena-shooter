# Project Structure

## Libraries

The game uses the external "classic" (https://github.com/rxi/classic) library for easier object handling in LUA.

## How the Game Works

A top-down 2D arena shooter built with LÖVE 2D. The player moves around a tile-based map and aims with a crosshair. The map defines the playable area with floor and wall tiles.

## Data Model

### Map

The `Map` class (`classes/map/init.lua`) loads a 2D grid of integer tile types from an external Lua file (e.g. `maps/default.lua`) and converts each cell into a `MapElement` object. It is a container that extends `Object` directly — it represents the world itself, not a thing in the world.

The map keeps both the raw integer grid (`self.grid`) for quick lookups and the object grid (`self.elements`) for type-safe queries. It provides `getElementAt(x, y)` to retrieve elements and `isPassable(x, y)` to check passability.

Map configuration constants (tile size, grid dimensions, tile type integers) live in `classes/map/config.lua`.

### Map Elements

Map elements use an inheritance hierarchy built on `GameObject`:

```
GameObject (x, y, gameConfig)
  └── MapElement (col, row, passable)
        ├── Floor (passable=true)
        └── Wall (passable=false)
```

- **MapElement** (`classes/map/elements/mapElement.lua`) — base class for all grid-occupying objects. Computes pixel position from grid coordinates. Carries a `passable` flag and provides `isPassable()`.
- **Floor** (`classes/map/elements/floor.lua`) — walkable tile. Rendered efficiently by the MapRenderer's single background Quad.
- **Wall** (`classes/map/elements/wall.lua`) — impassable tile. Rendering is handled by MapRenderer.
- **Water** (`classes/map/elements/water.lua`) — impassable water tile. Rendering is handled by MapRenderer.

Map elements are pure data/logic — they carry no rendering state. This keeps the object hierarchy focused on game logic (passability, collision) while rendering is handled by a dedicated renderer.

### Player

The player has a position (x, y) in map-space pixel coordinates, a movement speed, a scale value, and an aim target in world space. Input is handled separately in `classes/player/input.lua`, configuration in `classes/player/config.lua`, and all sprite animation / drawing now lives in `classes/ui/playerRenderer.lua`.

### Weapon

The weapon is a world-space entity that stores position and scale only. Its module entrypoint lives at `classes/weapon/init.lua`, while the sprite sheet, quad setup, and draw call live in `classes/ui/weaponRenderer.lua` so rendering stays outside the model layer.

### Game

The `Game` class (`classes/game/init.lua`) is the central model coordinator. It owns the Map, Player, Weapon, and DebugOverlay instances and is responsible for initializing and updating them. It has no rendering logic — all drawing is handled by the renderer layer.

### Renderers

The renderer layer lives in `classes/ui/` and handles all drawing, separate from the game model.

- **GameRenderer** (`classes/ui/gameRenderer.lua`) — top-level renderer orchestrator. Created in `main.lua` with a reference to the `Game` model. Owns all sub-renderers and the map centering offset. Provides `draw()` for world-space rendering and `drawUI()` for screen-space UI.
- **MapRenderer** (`classes/ui/mapRenderer.lua`) — handles all map visuals. Loads textures (background, wall sprite), creates the tiled background quad, and pre-computes wall positions from the raw grid data. Reads the `Map` model but never modifies it.
- **PlayerRenderer** (`classes/ui/playerRenderer.lua`) — owns the player sprite sheet, animation timer, sprite quads, crosshair rendering, and temporary player debug visuals while reading the `Player` model for world state.
- **WeaponRenderer** (`classes/ui/weaponRenderer.lua`) — owns the weapon sprite sheet and quad data, and reproduces the previous weapon draw call while reading position and scale from the `Weapon` model.

This pattern separates concerns cleanly: model classes (`Game`, `Map`, `MapElement`) have zero `love.graphics` calls, and renderers read model data to produce visuals. When new entities need rendering (player, weapon), they follow the same pattern — a renderer in `classes/ui/` that reads the model.

### DebugOverlay

The `DebugOverlay` class (`classes/ui/debugOverlay.lua`) is a screen-space HUD element that displays diagnostic information (currently player coordinates). It reads the `debug` flag from `gameConfig` and only renders when it is `true`. It is drawn via `GameRenderer:drawUI()`, which is called after the map coordinate transform is popped so the overlay stays fixed on screen.

## Dataflow

1. **Configuration** (`conf.lua`): Love2D runs `love.conf` before creating the window. This sets the window title and fullscreen mode so they are correct from the very first frame.
2. **Initialization** (`love.load`): Pixel filter and window icon are applied. A `Game` instance is created (model), then a `GameRenderer` is created with a reference to the game (view).
3. **Update** (`love.update`): Delegates to `Game:update(dt)` for gameplay state, then `GameRenderer:update(dt)` for presentation-only state such as player animation timing.
4. **Draw** (`love.draw`): Two-phase rendering, handled entirely by `GameRenderer`:
   - **World space**: Applies `love.graphics.translate()` with the renderer's map centering offset, then calls `GameRenderer:draw()` (map via `MapRenderer`, player via `PlayerRenderer`, weapon via `WeaponRenderer`)
   - **Screen space**: After popping the transform, calls `GameRenderer:drawUI()` (debug overlay and future HUD elements)

## Why Things Are Implemented This Way

### External map data files
Map layouts live in `maps/*.lua` as plain Lua tables rather than being hardcoded in the Map class. This separates level design from rendering logic and makes it easy to add new maps by creating new data files.

### Shared coordinate translate
All game objects share a single `love.graphics.translate()` applied in `love.draw()`. This means every object uses map-space coordinates (origin at top-left of the map grid). The centering offset is computed by `GameRenderer` from the map's pixel dimensions. This approach keeps coordinate systems consistent, which is important for future collision detection between the player and wall tiles.

### Renderer separation
Model classes (`Game`, `Map`, `MapElement` subclasses, `Player`, `Weapon`) contain gameplay data and logic, while drawing is handled by renderer classes in `classes/ui/`. `MapRenderer` reads the raw grid integers from the `Map` model (not the `MapElement` hierarchy) to decide what to draw, pre-computing wall positions once at creation time for efficient per-frame iteration. `PlayerRenderer` and `WeaponRenderer` follow the same pattern for entity visuals so sprite assets, quads, and animation timers stay in the presentation layer.

### Tiled background via Quad
The background texture uses LÖVE's wrap mode (`"repeat"`) combined with a Quad sized to the full map area. This tiles the texture efficiently in a single draw call rather than drawing individual tiles in a loop.
