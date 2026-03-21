# Changelog

## 2026-03-21

- Added tile-based map system with 32x32 pixel grid (45x28 tiles)
- Map loads layout from external Lua data files (`maps/default.lua`)
- Tiled background rendering using `sprites/background.png`
- Wall tiles rendered as gray placeholder rectangles
- Default map includes border walls and a few interior wall segments for testing
- Map auto-centers on screen with pixel-perfect alignment
- All game objects now render in shared map-space coordinates via `love.graphics.translate`
- Window size set to 1440x900
- Migrated Map class from manual metatable OOP to classic library (`Object:extend()`)
