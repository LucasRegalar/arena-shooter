# Projectile Firing System

We're adding a projectile system that lets the player fire bullets that travel in the aim direction, have a configurable range, and get destroyed on wall contact or when range is exceeded.

This involves three sub-plans executed in order:
1. **Viewport** — refactor the hardcoded map centering into a stretch-to-fit viewport with coordinate conversion
2. **Mouse Aiming** — use the viewport's `screenToWorld()` to convert mouse position for aiming
3. **Projectile System** — the actual firing/bullet mechanic, decoupled via a `ProjectileManager`

---

## Sub-Plan A: Viewport (Stretch-to-Fit)

Currently the rendering transform is split across two places:
- `GameRenderer` computes a centering `translate(offsetX, offsetY)` hardcoded to the map pixel size
- `MapRenderer` applies `scale(mapConfig.scale, mapConfig.scale)` (hardcoded `2`) for tile rendering

We'll introduce a `Viewport` class that computes a single stretch-to-fit transform and provides screen↔world coordinate conversion. This eliminates the need to pass offsets around.

**Important distinction:** `mapConfig.scale` (currently `2`) defines the **game coordinate system** — it's the ratio between native tile pixels (16px) and game-world units (32px). The Viewport's scale is a separate concern: how game-world units map to screen pixels.

### New File: `classes/viewport.lua`

- [x] Create `Viewport` class (extends `Object`)
- [x] Constructor `Viewport:new(gameWidth, gameHeight)`
	- `gameWidth/gameHeight` = map dimensions in game coordinates (e.g. 1440×896)
	- Reads window size via `love.graphics.getDimensions()`
	- Computes `self.scale = min(windowW / gameW, windowH / gameH)` — uniform scale to fit
	- Computes centering offset for letterboxing:
		- `self.offsetX = floor((windowW - gameW * scale) / 2)`
		- `self.offsetY = floor((windowH - gameH * scale) / 2)`
- [x] `Viewport:apply()` — calls `love.graphics.translate(offsetX, offsetY)` then `love.graphics.scale(scale, scale)`. Called once per frame inside a push/pop in GameRenderer
- [x] `Viewport:screenToWorld(screenX, screenY)` — converts screen coords to game-world coords
	- `worldX = (screenX - self.offsetX) / self.scale`
	- `worldY = (screenY - self.offsetY) / self.scale`
	- Used by mouse aiming input

### Modify: `classes/game/init.lua`

- [x] Create Viewport after Map: `self.viewport = Viewport(self.map:getPixelWidth(), self.map:getPixelHeight())`
- [x] Viewport is accessible to other systems via `game.viewport`

### Modify: `classes/ui/gameRenderer.lua`

- [x] Remove hardcoded `offsetX`/`offsetY` computation from `GameRenderer:new()`
- [x] In `GameRenderer:draw()`, replace `translate(self.offsetX, self.offsetY)` with `self.game.viewport:apply()`
- [x] Everything inside the push/pop now goes through the viewport transform

### Modify: `classes/ui/mapRenderer.lua`

- [x] MapRenderer's internal `scale(mapConfig.scale)` stays — it maps native 16px tile data to 32px game coordinates. This is a different concern from the viewport's screen scaling.

---

## Sub-Plan B: Mouse Aiming

Uses the Viewport from Sub-Plan A to convert mouse screen position to world coordinates.

### Modify: `classes/player/input.lua`

- [x] Add `input.getMouseAimVector(playerX, playerY, viewport)` function
	- Gets mouse position via `love.mouse.getPosition()`
	- Converts to world coords via `viewport:screenToWorld(mouseX, mouseY)`
	- Computes direction vector from `(playerX, playerY)` to world mouse position
	- Computes distance (clamped to `crosshair_max_distance` for crosshair display)
	- Returns `directionX, directionY, distance` (same signature as `getAimVector`)

### Modify: `classes/player/init.lua`

- [x] Update `Player:update(dt)` signature to `Player:update(dt, viewport)`
- [x] Update `Player:updateAim()` to `Player:updateAim(viewport)`
	- Call existing `getAimVector()` first (gamepad)
	- If gamepad has no input (distance == 0), fall back to `getMouseAimVector(self.x, self.y, viewport)`
	- Gamepad takes priority when active — preserves controller experience

### Modify: `classes/game/init.lua`

- [x] Pass viewport to player update: `self.player:update(dt, self.viewport)`

---

## Sub-Plan C: Projectile System

### New Files

#### 1. `classes/projectile/config.lua`
- [ ] Create config module:
	- `speed = 800` — pixels/second
	- `size = 6` — collision hitbox side length (small square)
	- `max_range = 600` — max distance in pixels before auto-destroy
	- `fire_rate = 0.15` — minimum seconds between shots
	- `fire_gamepad_button = "rightshoulder"` — R1/RB

#### 2. `classes/projectile/init.lua` — Projectile class
- [ ] Extends `GameObject`
- [ ] Constructor `Projectile:new(x, y, dirX, dirY, config)`
	- Stores normalized direction, speed, size, halfSize
	- `alive = true` flag
	- `distanceTraveled = 0` — for range checking
- [ ] `Projectile:getMovementDelta(dt)` — returns dx, dy
- [ ] `Projectile:destroy()` — sets `alive = false`

#### 3. `classes/projectile/manager.lua` — ProjectileManager class
- [ ] Extends `Object` (not a positioned entity)
- [ ] Constructor `ProjectileManager:new(bumpWorld)`
	- Stores bumpWorld reference, empty projectile list, fire cooldown timer
- [ ] `ProjectileManager:update(dt, player)`
	- Decrements fire cooldown
	- `tryFire(player)` — checks input + cooldown → spawns projectile at `player.x, player.y` with `player.aimDirectionX/Y`
	- For each projectile:
		- Get movement delta, convert center→top-left for Bump
		- `bumpWorld:move()` with collision filter
		- Convert back to center coords, update position
		- Accumulate `distanceTraveled += sqrt(dx² + dy²)` — destroy if exceeds `max_range`
		- If any collision with wall → destroy
	- Remove dead projectiles (reverse iteration + `bumpWorld:remove()`)
- [ ] `ProjectileManager:getProjectiles()` — returns list for renderer
- [ ] Collision filter: `other.layer == "walls"` → `"touch"`, else `nil` (ignore player and other projectiles)

#### 4. `classes/ui/projectileRenderer.lua` — ProjectileRenderer class
- [ ] Constructor receives `projectileManager`
- [ ] `draw()` iterates all projectiles, draws a small filled circle at each position
- [ ] Simple bright color (yellow/white), no sprite for now

### Modified Files

#### 5. `classes/player/input.lua`
- [ ] Add `input.isFirePressed(config, playerIndex)`
	- Checks `love.mouse.isDown(1)` (left mouse button)
	- Checks gamepad `rightshoulder` if connected
	- Returns boolean

#### 6. `classes/player/config.lua`
- [ ] Add `fire_gamepad_button = "rightshoulder"`

#### 7. `classes/game/init.lua`
- [ ] Create `ProjectileManager` in `Game:new()` with `self.map.bumpWorld`
- [ ] Call `self.projectileManager:update(dt, self.player)` after weapon update

#### 8. `classes/ui/gameRenderer.lua`
- [ ] Create `ProjectileRenderer` in `GameRenderer:new()`
- [ ] Call `self.projectileRenderer:draw()` inside world-space block, after weapon

### Documentation

- [ ] Update `documentation/changelog.md`
- [ ] Update `documentation/project-structure.md`

---

## Data Flow

```
Game:update(dt)
  → map:update(dt)
  → player collision resolution (existing)
  → player:update(dt, viewport)              ← mouse aim via viewport
  → weapon:update(dt)
  → projectileManager:update(dt, player)
      → tryFire: check mouse/gamepad + cooldown → spawn
      → for each projectile: bump move + wall collision + range check
      → removeDeadProjectiles

GameRenderer:draw()
  → love.graphics.push()
  → viewport:apply()                          ← stretch-to-fit transform
      → mapRenderer:draw()                    (tiles scale internally via mapConfig.scale)
      → playerRenderer:draw()
      → weaponRenderer:draw()
      → projectileRenderer:draw()             ← NEW
  → love.graphics.pop()
  → debugOverlay:draw()                       (screen space)
```

---

## Key Design Decisions

- **Viewport class** replaces hardcoded offsets — provides stretch-to-fit scaling + `screenToWorld()` for mouse input, single source of truth for the world↔screen transform
- **`mapConfig.scale` unchanged** — it defines the game coordinate grid (16px→32px), a separate concern from viewport display scaling
- **ProjectileManager** owns projectile lifecycle — decoupled from Player, Weapon, and Game
- **Range-based lifetime** (`distanceTraveled`) — maps naturally to future weapon variety
- **Bump "touch" response** for walls — projectile stops at contact point
- **Small square hitbox** (6×6) — Bump is AABB-only
- **Mouse aim as gamepad fallback** — gamepad stick takes priority when active

## Verification

- Run game at different window sizes — map stretches to fit with correct aspect ratio
- Mouse cursor position maps correctly to world coordinates (crosshair follows mouse)
- Gamepad aim overrides mouse aim when right stick is active
- Left-click fires projectiles toward mouse cursor
- Gamepad R1/RB fires projectiles in aim direction
- Projectiles collide with walls and disappear
- Projectiles disappear after traveling `max_range` distance in open space
- Rapid clicking respects fire rate cooldown
- Multiple projectiles can exist simultaneously
