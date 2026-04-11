# Coordinate System Refactor with push.lua

Replace our custom Viewport class with the push.lua library and collapse the two-stage scaling (mapConfig.scale + Viewport.scale) into a single stage. The game will work entirely in native Tiled coordinates (16px tiles, 720x448 world), and push.lua handles all scaling to screen.

## Why

We currently have 3 coordinate systems with 2 separate scale factors:
1. **Native Tiled** (16px tiles) — STI map data lives here
2. **Game-World** (32px tiles, 1440x896) — all entities, collision, gameplay
3. **Screen** (physical pixels) — display output

The `mapConfig.scale = 2` bridges (1→2), and `Viewport.scale` bridges (2→3). This means every new feature must reason about which space it's in. By collapsing to a single coordinate system (native Tiled space), we eliminate an entire layer of mental overhead.

## After the refactor

One coordinate system: **native Tiled space (16px tiles, 720x448)**. push.lua scales this to screen. Done.

## Implementation — Phase 1: Integrate push.lua, replace Viewport (no number changes)

Wire up push.lua at the current 1440x896 virtual resolution first, so we can verify push works before changing any numbers.

- [x] `conf.lua` — remove fullscreen settings (push will own the window)
- [x] `main.lua` — require push, call `push:setupScreen(720, 448, screenW, screenH, { fullscreen = true })`, add `love.resize` callback
- [x] `classes/ui/gameRenderer.lua` — replace `viewport:apply()` / `love.graphics.pop()` with `push:start()` / `push:finish()`
- [x] `classes/datamodel/player/input.lua` — replace `viewport:screenToWorld()` with `push:toGame()`, add nil guard for letterbox area
- [x] `classes/datamodel/player/init.lua` — remove `viewport` parameter from `update()` and `updateAim()`
- [x] `classes/datamodel/game/init.lua` — remove Viewport require and `self.viewport` creation, remove viewport from `self.player:update()` call
- [x] Delete `classes/ui/viewport.lua`

## Implementation — Phase 2: Collapse to native Tiled coordinates (720x448)

Switch push virtual resolution to 720x448 and halve all game-world constants.

- [x] `main.lua` — set push virtual resolution to 720x448
- [x] `classes/datamodel/map/config.lua` — remove `scale = 2`
- [x] `classes/datamodel/map/init.lua` — replace `config.tile_size * config.scale` with `config.tile_size` (bump world cell size, tile rects, getPixelWidth/Height)
- [x] `classes/ui/mapRenderer.lua` — remove `mapConfig` require, remove the `push/scale/pop` block around layer drawing (STI now draws at native 16px = game coordinates)
- [x] `classes/datamodel/player/config.lua` — halve spatial values:
	- `move_speed`: 300 → 150
	- `crosshair_max_distance`: 60 → 30
	- `crosshair_radius`: 6 → 3
	- `crosshair_line`: 10 → 5
	- `hand_distance`: 10 → 5
- [x] `classes/datamodel/player/init.lua`:
	- `Player.halfWidth`: 14 → 7
	- `Player.halfHeight`: 14 → 7
	- `self.scale`: `32/20` → `16/20` (0.8)
	- Default spawn fallback: 300 → 150
- [x] `classes/datamodel/game/init.lua` — halve player spawn position: `Player(300, 300, 1)` → `Player(150, 150, 1)`
- [x] `classes/datamodel/projectile/config.lua` — halve spatial values:
	- `speed`: 800 → 400
	- `size`: 6 → 3
	- `max_range`: 600 → 300
- [x] `classes/datamodel/weapon/init.lua` — `self.scale`: 1.5 → 0.75
- [x] `classes/datamodel/projectile/manager.lua` — checked, no hardcoded spatial values (all from config)
- [x] Renderers (playerRenderer, weaponRenderer, projectileRenderer) — checked, all read from model/config

## Verification

- Walk the player into walls from all angles — collision slide behavior should be unchanged
- Aim with mouse and gamepad — crosshair should follow correctly
- Move mouse into letterbox/pillarbox area — aim should not break (nil guard)
- Fire projectiles — they should travel correct distance and collide with walls
- Sprites should look crisp (nearest-neighbor filtering through push canvases)
- Debug overlay should still render in screen space
- Compare visual output before/after — should be pixel-identical at same window size
