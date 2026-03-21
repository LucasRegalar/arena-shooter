--- Game renderer.
-- Orchestrates all rendering for the game. Owns individual renderers (starting
-- with MapRenderer) and computes view-level layout such as the map centering offset.
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
--- @field offsetX number Horizontal pixel offset to center the map on screen
--- @field offsetY number Vertical pixel offset to center the map on screen
local GameRenderer = Object:extend()

--- Creates a new GameRenderer.
-- Initializes all sub-renderers and computes the map centering offset.
--- @param game Game The game model to render (read-only data source)
function GameRenderer:new(game)
	self.game = game

	-- Use nearest-neighbor filtering for crisp pixel art
	love.graphics.setDefaultFilter("nearest", "nearest")

	self.mapRenderer = MapRenderer(game.map)
	self.playerRenderer = PlayerRenderer(game.player, playerConfig)
	self.weaponRenderer = WeaponRenderer(game.weapon)

	-- Compute centering offset to position the map in the middle of the window
	local windowWidth, windowHeight = love.graphics.getDimensions()
	self.offsetX = math.floor((windowWidth - game.map:getPixelWidth()) / 2)
	self.offsetY = math.floor((windowHeight - game.map:getPixelHeight()) / 2)
end

--- Updates time-based renderer state.
-- Keeps presentation-only animation state outside the game model.
--- @param dt number Delta time since the last frame
function GameRenderer:update(dt)
	self.playerRenderer:update(dt)
end

--- Draws the entire game frame.
-- First draws world-space entities (map, player, weapon) inside a coordinate
-- transform that centers the map on screen, then draws screen-space UI elements
-- (debug overlay, HUD) outside the transform.
function GameRenderer:draw()
	-- World space: apply map centering offset
	love.graphics.push()
	love.graphics.translate(self.offsetX, self.offsetY)

	self.mapRenderer:draw()

	if self.game.weapon.isFacingLeft then
		self.weaponRenderer:draw()
		self.playerRenderer:draw()
	else
		self.playerRenderer:draw()
		self.weaponRenderer:draw()
	end

	love.graphics.pop()

	-- Screen space: UI elements stay fixed regardless of camera position
	-- Temporary: delegate to debug overlay until UI rendering is separated
	self.game.debugOverlay:draw(self.game.player)
end

return GameRenderer
