local Player = require("classes.player.init")
local Weapon = require("classes.weapon.init")
local Map = require("classes.map.init")
local DebugOverlay = require("classes.ui.debugOverlay")

local Game = Object:extend()

function Game:new()
	self.map = Map("maps.default")
	self.player = Player(300, 300, 1)
	self.weapon = Weapon(100, 100)
	self.debugOverlay = DebugOverlay()
end

function Game:update(dt)
	self.player:update(dt)
end

return Game
