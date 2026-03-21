# Changelog

## 2026-03-21

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
