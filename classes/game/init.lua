--- Game class.
-- Central game object that owns and coordinates all game entities (map, player, weapon).
-- Responsible for initializing, updating, and drawing the game world.

local Player = require("classes.player.init")
local Weapon = require("classes.weapon")
local Map = require("classes.map.init")
local DebugOverlay = require("classes.ui.debugOverlay")

--- @class Game
--- @field map Map The tile-based game map
--- @field player Player The player entity
--- @field weapon Weapon The weapon entity
--- @field debugOverlay DebugOverlay Screen-space debug information display
local Game = Object:extend()

--- Creates a new Game instance.
-- Initializes the map, player, and weapon with their default values.
function Game:new()
	self.map = Map("maps.default")
	self.player = Player(300, 300, 1)
	self.weapon = Weapon(100, 100)
	self.debugOverlay = DebugOverlay()
end

--- Updates all game entities.
-- @param dt number Delta time since the last frame
function Game:update(dt)
	self.player:update(dt)
end

--- Returns the map's centering offset for positioning in screen space.
-- @return number offset_x Horizontal offset in pixels
-- @return number offset_y Vertical offset in pixels
function Game:getMapOffset()
	return self.map:getOffset()
end

--- Draws all game entities.
-- Expects the caller to have already applied the appropriate coordinate transform.
function Game:draw()
	self.map:draw()
	self.player:draw()
	self.player:drawAim()
	self.weapon:draw()
end

--- Draws screen-space UI elements (debug overlay, HUD).
-- Must be called outside the map coordinate transform so elements stay
-- fixed on screen regardless of camera position.
function Game:drawUI()
	self.debugOverlay:draw(self.player)
end

return Game
