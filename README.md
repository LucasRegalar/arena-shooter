![Hero](assets/images/hero.jpg)

Love Love Love is a top-down arena shooter built with [Love2D](https://love2d.org/). Players navigate a tile-based map, aim with gamepad or mouse, and fire projectiles that collide with walls. The game features pixel-art sprites, Tiled-based map editing, and smooth wall-sliding movement.

## Roadmap

| Feature | Status |
|---|---|
| Player movement (keyboard + gamepad) | ✅ |
| Player aiming (gamepad + mouse fallback) | ✅ |
| Crosshair rendering | ✅ |
| Player sprite & idle animation | ✅ |
| Weapon positioning & rotation | ✅ |
| Firing system with cooldown | ✅ |
| Projectile movement & range-based lifetime | ✅ |
| Projectile–wall collision | ✅ |
| Player–wall collision (wall-sliding) | ✅ |
| Tiled map loading & rendering (STI) | ✅ |
| Stretch-to-fit viewport with letterboxing | ✅ |
| Debug overlay | ✅ |

## Project Structure

```
├── main.lua                  # Entry point (love.load, love.update, love.draw)
├── conf.lua                  # Love2D window configuration
├── classes/
│   ├── gameObject.lua        # Base class for world entities
│   ├── viewport.lua          # Stretch-to-fit camera with centering
│   ├── game/
│   │   ├── init.lua          # Game orchestrator (owns all entities, runs update loop)
│   │   └── config.lua        # Debug flag
│   ├── map/
│   │   ├── init.lua          # Map model (Tiled via STI, Bump collision world)
│   │   └── config.lua        # Tile size, scale, grid dimensions
│   ├── player/
│   │   ├── init.lua          # Player model (position, aim, facing)
│   │   ├── config.lua        # Speed, deadzone, crosshair distance
│   │   └── input.lua         # Input queries (keyboard, gamepad, mouse)
│   ├── weapon/
│   │   └── init.lua          # Weapon model (angle, position relative to player)
│   ├── projectile/
│   │   ├── init.lua          # Projectile model (position, direction, distance)
│   │   ├── config.lua        # Speed, size, max range
│   │   └── manager.lua       # Lifecycle: spawn → move → collide → destroy
│   └── ui/                   # Renderers (presentation only, no game logic)
│       ├── gameRenderer.lua
│       ├── mapRenderer.lua
│       ├── playerRenderer.lua
│       ├── weaponRenderer.lua
│       ├── projectileRenderer.lua
│       └── debugOverlay.lua
├── assets/
│   ├── maps/                 # Tiled map exports + source files
│   ├── images/               # Icons, backgrounds
│   └── sprites/              # Character & weapon sprite sheets
├── lib/                      # Third-party: classic, bump, anim8, sti
└── documentation/            # Changelogs, plans, architecture notes
```

## Architecture

### Model–View Separation

The codebase splits cleanly into **model** and **view** layers:

- **Model** (`classes/`): Pure game logic. `Game` orchestrates updates across `Map`, `Player`, `Weapon`, and `ProjectileManager`. No rendering code lives here.
- **View** (`classes/ui/`): Renderers read model state and draw. `GameRenderer` delegates to sub-renderers for map, player, weapon, and projectiles.

### Game Loop

```
love.load()
  └─ Game() creates Map → Viewport → Player → Weapon → ProjectileManager
  └─ GameRenderer(game) creates sub-renderers

love.update(dt)
  └─ Game:update(dt)
       ├─ Map:update(dt)              # Tile animations
       ├─ Player movement             # Read input → normalize → Bump:move() with wall-sliding
       ├─ Player:update(dt)           # Aim direction (gamepad stick or mouse fallback)
       ├─ Weapon:update()             # Follow hand position, compute angle to crosshair
       └─ ProjectileManager:update()  # Cooldown → fire → move → collide → cleanup

love.draw()
  └─ GameRenderer:draw()
       ├─ [World space] Viewport:apply() (translate + scale)
       │    ├─ MapRenderer:draw()
       │    ├─ WeaponRenderer / PlayerRenderer (layered by facing direction)
       │    └─ ProjectileRenderer:draw()
       └─ [Screen space] DebugOverlay:draw()
```

### Coordinate System

The game uses three coordinate spaces:

1. **Native tile space** — 16×16 px per tile (Tiled editor native)
2. **Game space** — 32×32 px per tile (scaled 2×), used by all entities and the Bump collision world
3. **Screen space** — Game space scaled uniformly by `Viewport` to fit the window, with centering offset for letterboxing

Entities store their **center** coordinates. Bump expects **top-left** coordinates, so conversions happen at movement boundaries. The `Viewport` handles screen-to-world conversion for mouse aiming.

### Libraries

| Library | Purpose |
|---|---|
| [classic](https://github.com/rxi/classic) | Lightweight OOP (Object:extend()) |
| [bump](https://github.com/kikito/bump.lua) | AABB collision detection with spatial hashing |
| [anim8](https://github.com/kikito/anim8) | Sprite grid & frame animation |
| [STI](https://github.com/karai17/Simple-Tiled-Implementation) | Tiled map loading & rendering |
