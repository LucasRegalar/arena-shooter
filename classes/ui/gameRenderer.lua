--- Game renderer.
-- Orchestrates all rendering for the game. Owns individual renderers and delegates
-- the world-to-screen transform to the Viewport owned by the Game model.
-- Receives the Game model as a read-only data source.

local MapRenderer = require("classes.ui.mapRenderer")
local playerConfig = require("classes.player.config")
local PlayerRenderer = require("classes.ui.playerRenderer")
local WeaponRenderer = require("classes.ui.weaponRenderer")

--- @class GameRenderer : Object
--- @field game Game Read-only reference to the game model
--- @field mapRenderer MapRenderer Renderer for the tile-based map
--- @field playerRenderer PlayerRenderer Renderer for the player entity
--- @field weaponRenderer WeaponRenderer Renderer for the weapon entity
local GameRenderer = Object:extend()

--- Creates a new GameRenderer.
-- Initializes all sub-renderers. The world-to-screen transform is handled by
-- the Viewport instance on the Game model.
--- @param game Game The game model to render (read-only data source)
function GameRenderer:new(game)
	self.game = game

	-- Use nearest-neighbor filtering for crisp pixel art
	love.graphics.setDefaultFilter("nearest", "nearest")

	self.mapRenderer = MapRenderer(game.map)
	self.playerRenderer = PlayerRenderer(game.player, playerConfig)
	self.weaponRenderer = WeaponRenderer(game.weapon)
end

--- Updates time-based renderer state.
-- Keeps presentation-only animation state outside the game model.
--- @param dt number Delta time since the last frame
function GameRenderer:update(dt)
	self.playerRenderer:update(dt)
end

--- Draws the entire game frame.
-- First draws world-space entities (map, player, weapon) inside the viewport
-- transform (stretch-to-fit + centering), then draws screen-space UI elements
-- (debug overlay, HUD) outside the transform.
function GameRenderer:draw()
	-- World space: apply viewport stretch-to-fit transform
	love.graphics.push()
	self.game.viewport:apply()

	self.mapRenderer:draw()
	self.playerRenderer:draw()
	self.weaponRenderer:draw()

	love.graphics.pop()

	-- Screen space: UI elements stay fixed regardless of camera position
	-- Temporary: delegate to debug overlay until UI rendering is separated
	self.game.debugOverlay:draw(self.game.player)
end

return GameRenderer
