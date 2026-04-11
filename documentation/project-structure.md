# Project Structure

## Libraries

- **classic** (https://github.com/rxi/classic) — OOP library for easier class handling in Lua.
- **STI** (https://github.com/karai17/Simple-Tiled-Implementation) — Tiled map loader and renderer for LÖVE. Lives in `lib/sti/`. Handles tileset image loading, SpriteBatch rendering, and tile animations.
- **bump** (https://github.com/kikito/bump.lua) — Lightweight AABB collision detection library. Lives in `lib/bump.lua`. Provides a spatial hash world with `move()` for collision resolution and built-in response types (slide, touch, cross, bounce).
- **push** (https://github.com/Ulydev/push) — Resolution-independence library for LÖVE. Lives in `lib/push.lua`. Renders to an offscreen canvas at a fixed virtual resolution (720x448) and scales it to fit the screen with letterboxing. Provides `push:toGame()` and `push:toReal()` for screen↔game coordinate conversion.

## How the Game Works

A top-down 2D arena shooter built with LÖVE 2D. The player moves around a tile-based map and aims with a crosshair. The map defines the playable area with floor and wall tiles.

## Data Model

### Map

The `Map` class (`classes/datamodel/map/init.lua`) loads a Tiled-exported Lua map via STI with the Bump plugin and owns both the STI map instance (`self.tiledMap`) and the Bump collision world (`self.bumpWorld`).

Collision geometry is built manually from the passability grid rather than using STI's bump plugin (which doesn't support chunked maps). The Bump collision world uses the same 16px tile coordinates as everything else.

A passability grid (`self.passability`) is also maintained as a 2D boolean table for grid-based queries via `isPassable(x, y)`.

Map configuration constants (tile size, grid dimensions) live in `classes/datamodel/map/config.lua`. The game operates in native Tiled coordinates (16px tiles). push.lua handles all scaling to screen resolution.

### Player

The player has a position (x, y) in map-space pixel coordinates, a movement speed, a scale value, an aim target in world space, and a left-facing flag derived from aim input. Input is handled separately in `classes/datamodel/player/input.lua`, configuration in `classes/datamodel/player/config.lua`, and all sprite animation / drawing now lives in `classes/ui/playerRenderer.lua`.

### Weapon

The weapon is a world-space entity that stores position, scale, an aim angle derived from the vector between the player's hand position and crosshair, and a left-facing flag used to keep the sprite visually upright when aiming behind the player. Its module entrypoint lives at `classes/datamodel/weapon/init.lua`, while the sprite sheet, quad setup, and draw call live in `classes/ui/weaponRenderer.lua` so rendering stays outside the model layer.

### Game

The `Game` class (`classes/datamodel/game/init.lua`) is the central model coordinator. It owns the Map, Player, Weapon, and DebugOverlay instances and is responsible for initializing and updating them. It has no rendering logic — all drawing is handled by the renderer layer.

### Renderers

The renderer layer lives in `classes/ui/` and handles all drawing, separate from the game model.

- **GameRenderer** (`classes/ui/gameRenderer.lua`) — top-level renderer orchestrator. Created in `main.lua` with a reference to the `Game` model. Owns all sub-renderers. Uses `push:start()`/`push:finish()` for world-space rendering, then draws screen-space UI afterward. Decides whether the weapon renders in front of or behind the player based on aim direction.
- **MapRenderer** (`classes/ui/mapRenderer.lua`) — handles all map visuals. Fills a dark background color for the floor area, then delegates tile rendering to the STI map instance at native 16px tile coordinates. Reads the `Map` model but never modifies it.
- **PlayerRenderer** (`classes/ui/playerRenderer.lua`) — owns the player sprite sheet, animation timer, sprite quads, crosshair rendering, and temporary player debug visuals while reading the `Player` model for world state, including whether the sprite should face left.
- **WeaponRenderer** (`classes/ui/weaponRenderer.lua`) — owns the weapon sprite sheet and quad data, and reproduces the previous weapon draw call while reading position and scale from the `Weapon` model.

This pattern separates concerns cleanly: model classes (`Game`, `Map`, `Player`, `Weapon`) have zero `love.graphics` calls, and renderers read model data to produce visuals. When new entities need rendering, they follow the same pattern — a renderer in `classes/ui/` that reads the model.

### DebugOverlay

The `DebugOverlay` class (`classes/ui/debugOverlay.lua`) is a screen-space HUD element that displays diagnostic information (currently player coordinates). It reads the `debug` flag from `gameConfig` and only renders when it is `true`. It is drawn via `GameRenderer:drawUI()`, which is called after the map coordinate transform is popped so the overlay stays fixed on screen.

## Dataflow

1. **Configuration** (`conf.lua`): Love2D runs `love.conf` before creating the window. This sets the window title and icon.
2. **Initialization** (`love.load`): push.lua sets up a 720x448 virtual resolution with fullscreen and canvas-based scaling. Pixel filter is set to nearest-neighbor. A `Game` instance is created (model), then a `GameRenderer` is created with a reference to the game (view).
3. **Update** (`love.update`): Delegates to `Game:update(dt)` for gameplay state (including STI map tile animations). During this update, the player refreshes hand position, crosshair position, and left-facing state from aim input, then the weapon derives its world position and aim angle from that player state. Afterward, `GameRenderer:update(dt)` advances presentation-only state such as player animation timing.
4. **Draw** (`love.draw`): Two-phase rendering, handled entirely by `GameRenderer`:
   - **World space**: `push:start()` begins rendering to the virtual resolution canvas. Map, player, weapon, and projectiles are drawn in game coordinates. `push:finish()` scales the canvas to screen with letterboxing.
   - **Screen space**: After `push:finish()`, screen-space UI elements (debug overlay) are drawn in raw screen pixels.

## Why Things Are Implemented This Way

### Tiled map workflow
Maps are authored in the Tiled editor (https://www.mapeditor.org/) and exported as Lua files into `maps/`. STI loads these exports directly, handling tileset images, tile rendering, and animations. This separates level design tooling from game code and provides a visual editor for map creation.

### Single coordinate system via push.lua
The game operates in a single coordinate system: native Tiled tile coordinates (16px tiles, 720x448 world). push.lua renders everything to an offscreen canvas at this virtual resolution, then scales it to fit the screen with letterboxing. Mouse input is converted back to game coordinates via `push:toGame()`. This eliminates the previous two-stage scaling (mapConfig.scale + Viewport.scale) and means all entities, collision rects, and rendering use the same coordinate space.

### Collision via Bump
The Bump library provides AABB collision detection with a spatial hash grid. The Map builds collision rects manually from its passability grid (STI's bump plugin doesn't support chunked maps). Collision rects use the same 16px tile coordinates as everything else. The Bump world is created and exposed by the Map model (`map.bumpWorld`). Player and projectile movement is resolved through `bumpWorld:move()` with slide and touch responses respectively.

### Renderer separation
Model classes in `classes/datamodel/` (`Game`, `Map`, `Player`, `Weapon`) contain gameplay data and logic — they have zero `love.graphics` calls. The `Map` model owns the STI map instance because STI is fundamentally map data that also knows how to render itself. All drawing is handled by renderer classes in `classes/ui/`, with `MapRenderer` calling through to STI's draw method. `PlayerRenderer` and `WeaponRenderer` follow the same pattern for entity visuals so sprite assets, quads, and animation timers stay in the presentation layer. In this setup, the player model computes its facing state from aim input, the weapon model computes its aim angle and left-facing state from gameplay state, and the renderer layer consumes that data to flip sprites and switch draw order where needed.

### Resolution independence
The game's virtual resolution (720x448) matches the native Tiled map dimensions (45 tiles x 16px, 28 tiles x 16px). push.lua handles all scaling to the physical display, including letterboxing and coordinate conversion. There is no intermediate "render scale" — the game works directly in native tile pixels, and push.lua makes it fill the screen.
