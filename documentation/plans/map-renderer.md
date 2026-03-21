# Map Renderer System

Introduce a renderer layer that separates all drawing from model code. The `Game` class becomes model-only, while a new `GameRenderer` orchestrates rendering from `main.lua`. We start with the map — a `MapRenderer` handles all map drawing.

## Architecture

```
main.lua
  ├── Game (model)          — owns Map, Player, Weapon
  │     └── Map             — pure data: grid, elements, passability
  └── GameRenderer (view)   — orchestrates all renderers
        ├── MapRenderer     — draws tiled background + walls
        └── (future: PlayerRenderer, WeaponRenderer, ...)
```

- `Game` has zero `love.graphics` calls — it's purely model/logic.
- `GameRenderer` is created in `main.lua`, receives the `Game` instance, and coordinates all drawing.
- `MapRenderer` receives the `Map` as a read-only data source, owns all map textures/quads, and handles draw calls.
- `GameRenderer` owns the map offset computation (view concern) and exposes `getMapOffset()` for `main.lua` to apply the translate.

## Steps

- [ ] Create `classes/ui/mapRenderer.lua` — `MapRenderer` class
	- Extends `Object`
	- Constructor takes a `Map` instance
	- Loads `sprites/background.png`, sets repeat wrap, creates the background quad
	- Loads `sprites/wall.png`
	- Iterates `map.grid` once to pre-compute wall pixel positions into a flat list
	- `draw()`: draws background quad, then iterates wall positions drawing the wall sprite
- [ ] Create `classes/ui/gameRenderer.lua` — `GameRenderer` class
	- Extends `Object`
	- Constructor takes a `Game` instance
	- Creates `self.mapRenderer = MapRenderer(game.map)`
	- Computes and stores map offset using `game.map:getPixelWidth/Height()` and `love.graphics.getDimensions()`
	- `getMapOffset()`: returns the offset values
	- `draw()`: calls `self.mapRenderer:draw()`, then delegates to player/weapon draw (temporarily still calling `game.player:draw()`, `game.player:drawAim()`, `game.weapon:draw()` until those get their own renderers)
	- `drawUI()`: calls `game.debugOverlay:draw(game.player)` (temporary, until UI rendering is also separated)
- [ ] Strip rendering from `Map` (`classes/map/init.lua`)
	- Remove texture loading, quad creation, offset fields
	- Remove `Map:draw()` and `Map:getOffset()`
	- Stop passing `self.wallSprite` to `Wall()` constructor
	- Add `Map:getPixelWidth()` and `Map:getPixelHeight()`
- [ ] Strip rendering from `Wall` (`classes/map/elements/wall.lua`)
	- Remove `sprite` parameter, `self.sprite` field, and `Wall:draw()`
- [ ] Strip `draw()` no-op from `MapElement` (`classes/map/elements/mapElement.lua`)
- [ ] Update `Game` (`classes/game/init.lua`)
	- Remove `Game:draw()`, `Game:drawUI()`, and `Game:getMapOffset()`
	- Keep `Game:new()` and `Game:update(dt)` — model only
- [ ] Update `main.lua`
	- Require and create `GameRenderer` after `Game`
	- `love.draw()`: get offset from `gameRenderer:getMapOffset()`, call `gameRenderer:draw()` and `gameRenderer:drawUI()`
- [ ] Update documentation
	- `documentation/changelog.md` — document the renderer introduction
	- `documentation/project-structure.md` — describe the renderer pattern and data flow

## Files to modify

| File | Action |
|------|--------|
| `classes/ui/mapRenderer.lua` | **Create** — MapRenderer class |
| `classes/ui/gameRenderer.lua` | **Create** — GameRenderer orchestrator |
| `classes/map/init.lua` | **Edit** — strip all rendering, add pixel dimension helpers |
| `classes/map/elements/wall.lua` | **Edit** — remove sprite and draw |
| `classes/map/elements/mapElement.lua` | **Edit** — remove draw no-op |
| `classes/game/init.lua` | **Edit** — remove draw/drawUI/getMapOffset |
| `main.lua` | **Edit** — wire up GameRenderer |
| `documentation/changelog.md` | **Edit** — log changes |
| `documentation/project-structure.md` | **Edit** — describe renderer pattern |

## Verification

- Run the game (`love .`) and confirm the map renders identically — tiled floor background, walls in correct positions
- Confirm `Map`, `MapElement`, `Wall`, `Floor`, and `Game` have zero `love.graphics` calls
- Confirm player, weapon, and debug overlay rendering still work (temporarily called through GameRenderer)
