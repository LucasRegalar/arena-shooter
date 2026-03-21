# Collision Detection: Player vs Map Tiles

The player can currently walk through walls and water because `handleMovement` applies position changes without checking tile passability. We'll add a tile-based collision system where a dedicated collision module resolves movement, orchestrated by Game — keeping Player free of map knowledge.

## Context

- Player position `(self.x, self.y)` is the sprite's center/pivot in pixel coordinates
- Player visual bounds are 32x32 (20px sprite scaled by 32/20)
- Tile size is 32x32, grid is 1-based: `pixel = (grid - 1) * 32`
- `Map:isPassable(grid_x, grid_y)` already exists and returns false for walls, water, and out-of-bounds
- Movement currently: `self.x += moveInputX * speed * dt` with no collision checks

## Architecture

**Collision module** (`classes/collision.lua`) — stateless utility with pure functions. Takes a map + entity geometry, returns resolved positions. Reusable for any entity type.

**Game orchestrates** — Game calls collision resolution between player movement intent and the map. Player never receives or knows about the map.

**Player exposes intent** — Player provides its movement delta and hitbox dimensions. Game reads these and delegates collision resolution to the collision module.

### Update flow

```
Game:update(dt)
  1. player:getMovementDelta(dt)  →  returns (dx, dy)
  2. collision.resolveMovement(map, player.x, player.y, dx, dy, player.hitboxHalfW, player.hitboxHalfH)  →  returns (newX, newY)
  3. player.x, player.y = newX, newY
  4. player:update(dt)  →  aim + animation only
```

## Approach: Axis-Separated AABB Collision

We resolve X and Y movement independently. This gives wall-sliding for free — when moving diagonally into a wall, the blocked axis stops but the free axis keeps moving. This is standard for tile-based games and feels natural.

## Why Not Check Both Axes at Once?

When we check both axes simultaneously, diagonal movement toward a wall causes the player to get completely stuck — even though one axis is free to move. Here's why:

Consider a player walking diagonally down-right (dx=+3, dy=+3) toward a wall that is only to the right:

```
  ┌────┐
  │    │
  │ P ──────► wall
  │    │
  └──│─┘
     ▼
   (free)
```

**Combined check (broken):** We test the position (x+3, y+3) as a single point. The bbox at that combined position overlaps the wall tile to the right. The entire movement is rejected. The player stops dead — even though moving downward alone would have been perfectly fine. The player feels "glued" to the wall and can't escape without releasing the horizontal input first.

**Axis-separated check (correct):** We test X first: position (x+3, y) overlaps the wall → reject X, keep old X. Then test Y: position (x, y+3) is clear → accept Y. The player slides smoothly along the wall downward. This matches how collision works in virtually all 2D tile-based games.

The axis-separated approach also handles corners naturally. When both axes are blocked (walking into a corner), both checks fail independently and the player stops on both axes — no special corner-case logic needed.

## Implementation Steps

### 1. Create collision utility module (`classes/collision.lua`)
- [ ] Create `classes/collision.lua` with two functions:
  - `canOccupy(map, centerX, centerY, halfW, halfH)` — compute which grid cells the bounding box overlaps, return `true` only if all overlapped cells are passable
    - Grid cell calculation: `math.floor(pixelEdge / tile_size) + 1` for each edge of the bbox
    - Iterate all cells from top-left to bottom-right corner of the bbox
  - `resolveMovement(map, oldX, oldY, dx, dy, halfW, halfH)` — axis-separated resolution:
    - Try X: if `canOccupy(map, oldX + dx, oldY, halfW, halfH)` then apply dx, else keep oldX
    - Try Y: if `canOccupy(map, resolvedX, oldY + dy, halfW, halfH)` then apply dy, else keep oldY
    - Return (resolvedX, resolvedY)

### 2. Add hitbox fields to Player (`classes/player/init.lua`, `classes/player/config.lua`)
- [ ] Add `hitbox_half_width = 14` and `hitbox_half_height = 14` to player config (slightly smaller than full 16px half-tile for forgiving corner navigation)
- [ ] In `Player:new`, set `self.hitboxHalfW` and `self.hitboxHalfH` from config

### 3. Refactor Player movement intent (`classes/player/init.lua`)
- [ ] Rename `handleMovement(dt)` → `getMovementDelta(dt)` — computes and returns `(dx, dy)` without modifying `self.x`/`self.y`
- [ ] Remove movement from `Player:update(dt)` — it now only calls `updateAim()` and `updateAnimation(dt)`

### 4. Wire collision in Game:update (`classes/game/init.lua`)
- [ ] `require` the collision module
- [ ] In `Game:update(dt)`:
  - Call `player:getMovementDelta(dt)` to get `(dx, dy)`
  - Call `collision.resolveMovement(self.map, player.x, player.y, dx, dy, player.hitboxHalfW, player.hitboxHalfH)` to get resolved position
  - Set `player.x, player.y` to the resolved position
  - Then call `player:update(dt)` for aim + animation

### 5. Documentation updates
- [ ] Update `documentation/changelog.md` with the collision detection addition
- [ ] Update `documentation/project-structure.md`:
  - Add Collision section to Data Model
  - Update Player section to mention hitbox and movement intent
  - Update Game section to mention collision orchestration
  - Update Dataflow to mention collision resolution during update

## Files to Modify

| File | Change |
|---|---|
| `classes/collision.lua` | **New** — stateless collision utility module |
| `classes/player/config.lua` | Add hitbox half-width/half-height |
| `classes/player/init.lua` | Add hitbox fields, rename handleMovement → getMovementDelta (returns dx/dy), remove movement from update |
| `classes/game/init.lua` | Require collision module, orchestrate movement resolution before player:update |
| `documentation/changelog.md` | Log the change |
| `documentation/project-structure.md` | Document collision system and updated architecture |

## Verification

- Run the game, walk toward a wall — player should stop at the wall edge
- Walk diagonally along a wall — player should slide smoothly
- Walk into a corner — player should stop on both axes
- Walk on floor tiles — movement should feel identical to before
- Walk toward water — should block just like walls
- Walk toward map edges — should block (out-of-bounds returns false from isPassable)
