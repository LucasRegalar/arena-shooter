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
- **Floor** (`classes/map/elements/floor.lua`) — walkable tile. Its `draw()` is a no-op because all floors are rendered efficiently by the Map's single background Quad.
- **Wall** (`classes/map/elements/wall.lua`) — impassable tile. Holds a shared wall sprite reference and draws it at its pixel position.

This hybrid approach gives us a clean object hierarchy (every cell is a typed MapElement with passability info) while preserving the performance of a single draw call for all floor tiles.

### Player

The player has a position (x, y) in map-space pixel coordinates, a movement speed, and sprite animation state. Input is handled separately in `classes/player/input.lua`, configuration in `classes/player/config.lua`.

### Weapon

The weapon is a world-space entity rendered from the weapon sprite sheet. Its module entrypoint lives at `classes/weapon/init.lua`, which keeps it consistent with the other class packages and allows `require("classes.weapon")` to resolve through the directory module pattern.

### Game

The `Game` class (`classes/game/init.lua`) is the central coordinator. It owns the Map, Player, Weapon, and DebugOverlay instances and is responsible for initializing, updating, and drawing them. `main.lua` only handles LÖVE window setup and delegates to the Game object.

### DebugOverlay

The `DebugOverlay` class (`classes/ui/debugOverlay.lua`) is a screen-space HUD element that displays diagnostic information (currently player coordinates). It reads the `debug` flag from `gameConfig` and only renders when it is `true`. It is drawn via `Game:drawUI()`, which is called after the map coordinate transform is popped so the overlay stays fixed on screen.

## Dataflow

1. **Configuration** (`conf.lua`): Love2D runs `love.conf` before creating the window. This sets the window title and fullscreen mode so they are correct from the very first frame.
2. **Initialization** (`love.load`): Pixel filter and window icon are applied. A `Game` instance is created, which in turn creates Map, Player, and Weapon.
3. **Update** (`love.update`): Delegates to `Game:update(dt)`, which updates the player.
4. **Draw** (`love.draw`): Two-phase rendering:
   - **World space**: Applies `love.graphics.translate()` with the map's centering offset, then calls `Game:draw()` (map, player, aim, weapon)
   - **Screen space**: After popping the transform, calls `Game:drawUI()` (debug overlay and future HUD elements)

## Why Things Are Implemented This Way

### External map data files
Map layouts live in `maps/*.lua` as plain Lua tables rather than being hardcoded in the Map class. This separates level design from rendering logic and makes it easy to add new maps by creating new data files.

### Shared coordinate translate
All game objects share a single `love.graphics.translate()` applied in `Game:draw()`. This means every object uses map-space coordinates (origin at top-left of the map grid). This approach keeps coordinate systems consistent, which is important for future collision detection between the player and wall tiles.

### Tiled background via Quad
The background texture uses LÖVE's wrap mode (`"repeat"`) combined with a Quad sized to the full map area. This tiles the texture efficiently in a single draw call rather than drawing individual tiles in a loop.
