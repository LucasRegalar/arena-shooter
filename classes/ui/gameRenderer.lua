--- Game renderer.
-- Orchestrates all rendering for the game. Owns individual renderers (starting
-- with MapRenderer) and computes view-level layout such as the map centering offset.
-- Receives the Game model as a read-only data source.

local MapRenderer = require("classes.ui.mapRenderer")

--- @class GameRenderer : Object
--- @field game Game Read-only reference to the game model
--- @field mapRenderer MapRenderer Renderer for the tile-based map
--- @field offsetX number Horizontal pixel offset to center the map on screen
--- @field offsetY number Vertical pixel offset to center the map on screen
local GameRenderer = Object:extend()

--- Creates a new GameRenderer.
-- Initializes all sub-renderers and computes the map centering offset.
--- @param game Game The game model to render (read-only data source)
function GameRenderer:new(game)
	self.game = game

	self.mapRenderer = MapRenderer(game.map)

	-- Compute centering offset to position the map in the middle of the window
	local windowWidth, windowHeight = love.graphics.getDimensions()
	self.offsetX = math.floor((windowWidth - game.map:getPixelWidth()) / 2)
	self.offsetY = math.floor((windowHeight - game.map:getPixelHeight()) / 2)
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

	-- Temporary: delegate to entity draw methods until they get their own renderers
	self.game.player:draw()
	self.game.player:drawAim()
	self.game.weapon:draw()

	love.graphics.pop()

	-- Screen space: UI elements stay fixed regardless of camera position
	-- Temporary: delegate to debug overlay until UI rendering is separated
	self.game.debugOverlay:draw(self.game.player)
end

return GameRenderer
