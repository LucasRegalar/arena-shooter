# Changelog

## 2026-03-21

- Integrated STI (Simple Tiled Implementation) library for map rendering
- Maps are now authored in the Tiled editor and exported as Lua files (`maps/map.lua`)
- `Map` model loads via STI and derives a passability grid from tile GIDs (0 = passable, non-zero = wall)
- `MapRenderer` delegates all tile drawing to STI at 2x render scale (16px tiles → 32px on screen)
- Removed manual texture/sprite rendering (background quad, wall sprites, water sprites)
- Map elements (Floor/Wall/Water classes) are no longer used — passability is now a boolean grid
- Added `Map:update(dt)` for STI tile animation support
- Map config updated: `tile_size` is now 16 (native Tiled tile size), `scale = 2` for render scaling

- Added `Water` map element (`classes/map/elements/water.lua`) — impassable water tile
- Added `WATER = 2` tile type constant to map config
- `MapRenderer` now loads and draws `sprites/water.png` for water tiles
- Updated default map with a pond in the upper-right area

- Introduced renderer system to separate model code from drawing code
- Added `MapRenderer` (`classes/ui/mapRenderer.lua`) — handles all map textures, quads, and draw calls
- Added `GameRenderer` (`classes/ui/gameRenderer.lua`) — orchestrates all renderers and owns the map centering offset
- Made `Map` a pure data model — removed all `love.graphics` calls, textures, draw method, and offset computation
- Made `Game` model-only — removed `draw()`, `drawUI()`, and `getMapOffset()`; rendering now handled by `GameRenderer`
- Stripped rendering from `Wall` and `MapElement` — removed sprite references and draw methods
- Added `Map:getPixelWidth()` and `Map:getPixelHeight()` helper methods
- `main.lua` now creates and delegates to `GameRenderer` for all drawing

- Introduced `MapElement` base class (`classes/map/elements/mapElement.lua`) extending `GameObject` with grid position and passability
- Added `Floor` element (`classes/map/elements/floor.lua`) — passable, rendering handled by background Quad
- Added `Wall` element (`classes/map/elements/wall.lua`) — impassable, draws its own sprite
- Refactored `Map` to build a 2D grid of `MapElement` instances from raw tile data
- Added `Map:getElementAt()` and `Map:isPassable()` query methods
- Added debug overlay HUD (`classes/ui/debugOverlay.lua`) displaying player coordinates in the bottom-left corner with a semi-transparent black background, gated behind `gameConfig.debug`
- Added `Game:drawUI()` for screen-space UI rendering outside the map coordinate transform
- Added `conf.lua` for pre-window configuration (title, fullscreen) — fixes title not appearing everywhere on macOS
- Moved fullscreen settings from `main.lua` to `conf.lua`
- Moved the weapon module entrypoint from `classes/weapon/weapon.lua` to `classes/weapon/init.lua` so `require("classes.weapon")` resolves correctly again
- Added shared game configuration module in `classes/game/config.lua`
- Refactored `GameObject` into a reusable base class for world entities
- Player and Weapon now inherit from `GameObject` and receive the same shared `gameConfig` reference
- Added tile-based map system with 32x32 pixel grid (45x28 tiles)
- Map loads layout from external Lua data files (`maps/default.lua`)
- Tiled background rendering using `sprites/background.png`
- Wall tiles rendered as gray placeholder rectangles
- Default map includes border walls and a few interior wall segments for testing
- Map auto-centers on screen with pixel-perfect alignment
- All game objects now render in shared map-space coordinates via `love.graphics.translate`
- Window size set to 1440x900
- Migrated Map class from manual metatable OOP to classic library (`Object:extend()`)
- Extracted game logic from `main.lua` into `Game` class (`classes/game.lua`)
- Replaced gray placeholder rectangles with wall sprite (`sprites/wall.png`) for wall tiles
