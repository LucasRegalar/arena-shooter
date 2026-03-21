# Project Structure

## How the Game Works

A top-down 2D arena shooter built with LÖVE 2D. The player moves around a tile-based map and aims with a crosshair. The map defines the playable area with floor and wall tiles.

World entities such as the player and weapon now share a lightweight `GameObject` base class. Right now it mainly provides common world position storage and access to a shared game-wide configuration table.

## Data Model

### Map

The map is a 2D grid of integer tile types stored in a Lua table file (e.g. `maps/default.lua`). Each cell is either:
- `0` (floor) — walkable area, rendered with a tiled background texture
- `1` (wall) — impassable block, rendered as a gray rectangle (placeholder)

The grid is loaded by the `Map` class at construction time. Map dimensions are derived from the data (rows = number of sub-tables, columns = length of first sub-table).

Map configuration constants (tile size, colors) live in `classes/map/config.lua`.

### Player

The player has a position (x, y) in map-space pixel coordinates, a movement speed, sprite animation state, and a reference to the shared `gameConfig`. Input is handled separately in `classes/player/input.lua`, configuration in `classes/player/config.lua`, and shared base state comes from `classes/gameObject.lua`.

### Weapon

The weapon currently stores world position, draw scale, sprite data, and a reference to the shared `gameConfig`. It also inherits its base world state from `classes/gameObject.lua`.

### GameObject and shared config

`classes/gameObject.lua` is the base class for world entities that should share common state. For now it owns three fields: `x`, `y`, and `gameConfig`.

`classes/game/config.lua` stores the shared game-wide configuration table. `main.lua` requires this module once and passes the same table reference into each `GameObject`-based entity when it is created.

## Dataflow

1. **Initialization** (`love.load`): Window is set to fullscreen desktop mode. `main.lua` loads the shared `gameConfig`, creates the map, and passes that same config reference into `Player` and `Weapon`.
2. **Update** (`love.update`): Player reads input and updates position and animation.
3. **Draw** (`love.draw`):
    - A shared `love.graphics.translate()` is applied using the map's centering offset so all objects render in map-space coordinates.
    - Map draws first: tiled background, then wall tiles.
    - Player and weapon draw on top.

## Why Things Are Implemented This Way

### External map data files
Map layouts live in `maps/*.lua` as plain Lua tables rather than being hardcoded in the Map class. This separates level design from rendering logic and makes it easy to add new maps by creating new data files.

### Shared coordinate translate
All game objects share a single `love.graphics.translate()` applied in `main.lua`. This means every object uses map-space coordinates (origin at top-left of the map grid). This approach keeps coordinate systems consistent, which is important for future collision detection between the player and wall tiles.

### Lightweight `GameObject` base class
We use `GameObject` as a small inheritance layer for world entities instead of making each class create and own its own shared state. This gives us one place to centralize common entity data now (`x`, `y`, `gameConfig`) and a safe place to add future shared behavior later without changing every entity constructor again.

### Shared game configuration module
Shared game-wide settings live in a dedicated module rather than being recreated inside each object instance. This keeps configuration centralized, makes dependencies explicit in `main.lua`, and ensures all entities read from the same table reference.

### Tiled background via Quad
The background texture uses LÖVE's wrap mode (`"repeat"`) combined with a Quad sized to the full map area. This tiles the texture efficiently in a single draw call rather than drawing individual tiles in a loop.
