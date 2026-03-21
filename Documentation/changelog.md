# Changelog

## 2026-03-21

- Introduced `MapElement` base class (`classes/map/elements/mapElement.lua`) extending `GameObject` with grid position and passability
- Added `Floor` element (`classes/map/elements/floor.lua`) — passable, rendering handled by background Quad
- Added `Wall` element (`classes/map/elements/wall.lua`) — impassable, draws its own sprite
- Refactored `Map` to build a 2D grid of `MapElement` instances from raw tile data
- Added `Map:getElementAt()` and `Map:isPassable()` query methods
- Added debug overlay HUD (`classes/ui/debugOverlay.lua`) displaying player coordinates in the bottom-left corner with a semi-transparent black background, gated behind `gameConfig.debug`
- Added `Game:drawUI()` for screen-space UI rendering outside the map coordinate transform
- Added `conf.lua` for pre-window configuration (title, fullscreen) — fixes title not appearing everywhere on macOS
- Moved fullscreen settings from `main.lua` to `conf.lua`
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
