# Project Structure

## Libraries

The game uses the external "classic" (https://github.com/rxi/classic) library for easier object handling in LUA.

## How the Game Works

A top-down 2D arena shooter built with LÖVE 2D. The player moves around a tile-based map and aims with a crosshair. The map defines the playable area with floor and wall tiles.

## Data Model

### Map

The map is a 2D grid of integer tile types stored in a Lua table file (e.g. `maps/default.lua`). Each cell is either:
- `0` (floor) — walkable area, rendered with a tiled background texture
- `1` (wall) — impassable block, rendered as a gray rectangle (placeholder)

The grid is loaded by the `Map` class at construction time. Map dimensions are derived from the data (rows = number of sub-tables, columns = length of first sub-table).

Map configuration constants (tile size, colors) live in `classes/map/config.lua`.

### Player

The player has a position (x, y) in map-space pixel coordinates, a movement speed, and sprite animation state. Input is handled separately in `classes/player/input.lua`, configuration in `classes/player/config.lua`.

### Game

The `Game` class (`classes/game/init.lua`) is the central coordinator. It owns the Map, Player, and Weapon instances and is responsible for initializing, updating, and drawing them. `main.lua` only handles LÖVE window setup and delegates to the Game object.

## Dataflow

1. **Configuration** (`conf.lua`): Love2D runs `love.conf` before creating the window. This sets the window title and fullscreen mode so they are correct from the very first frame.
2. **Initialization** (`love.load`): Pixel filter and window icon are applied. A `Game` instance is created, which in turn creates Map, Player, and Weapon.
3. **Update** (`love.update`): Delegates to `Game:update(dt)`, which updates the player.
4. **Draw** (`love.draw`): Delegates to `Game:draw()`, which:
   - Applies a shared `love.graphics.translate()` using the map's centering offset
   - Draws map, player, player aim, and weapon in order

## Why Things Are Implemented This Way

### External map data files
Map layouts live in `maps/*.lua` as plain Lua tables rather than being hardcoded in the Map class. This separates level design from rendering logic and makes it easy to add new maps by creating new data files.

### Shared coordinate translate
All game objects share a single `love.graphics.translate()` applied in `Game:draw()`. This means every object uses map-space coordinates (origin at top-left of the map grid). This approach keeps coordinate systems consistent, which is important for future collision detection between the player and wall tiles.

### Tiled background via Quad
The background texture uses LÖVE's wrap mode (`"repeat"`) combined with a Quad sized to the full map area. This tiles the texture efficiently in a single draw call rather than drawing individual tiles in a loop.
