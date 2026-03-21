local Player = require("classes.player.init")
local Weapon = require("classes.weapon.init")
local Map = require("classes.map.init")
local Viewport = require("classes.viewport")
local DebugOverlay = require("classes.ui.debugOverlay")

local Game = Object:extend()

--- Collision filter: all wall collisions use "slide" response for wall-sliding behavior.
local function playerCollisionFilter(item, other)
	return "slide"
end

function Game:new()
	self.map = Map("maps/map.lua")
	self.viewport = Viewport(self.map:getPixelWidth(), self.map:getPixelHeight())
	self.player = Player(300, 300, 1)
	self.weapon = Weapon(self.player)
	self.debugOverlay = DebugOverlay()

	-- Register the player in the Bump world using top-left hitbox coordinates.
	-- Player position is center-based, so we offset by half the hitbox size.
	local hw, hh = self.player.halfWidth, self.player.halfHeight
	self.map.bumpWorld:add(
		self.player,
		self.player.x - hw,
		self.player.y - hh,
		hw * 2,
		hh * 2
	)
end

--- Updates all game entities.
-- Resolves player movement through the Bump collision world for wall-sliding.
function Game:update(dt)
	self.map:update(dt)

	-- Get the player's desired movement, then resolve through collision.
	-- Bump works in top-left coordinates, so we convert from center coords.
	local dx, dy = self.player:getMovementDelta(dt)
	local hw, hh = self.player.halfWidth, self.player.halfHeight
	local goalX = self.player.x - hw + dx
	local goalY = self.player.y - hh + dy

	local actualX, actualY = self.map.bumpWorld:move(
		self.player, goalX, goalY, playerCollisionFilter
	)

	-- Convert back from top-left to center coordinates
	self.player.x = actualX + hw
	self.player.y = actualY + hh

	self.player:update(dt, self.viewport)
	self.weapon:update(dt)
end

return Game
