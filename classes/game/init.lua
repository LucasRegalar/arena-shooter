--- Game class.
-- Central game model that owns and coordinates all game entities (map, player, weapon).
-- Responsible for initializing and updating the game world.
-- Rendering is handled separately by GameRenderer.

local Player = require("classes.player.init")
local Weapon = require("classes.weapon.init")
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

return Game
