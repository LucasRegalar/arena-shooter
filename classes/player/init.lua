local GameObject = require('classes.gameObject')

local playerConfig = require('classes.player.config')
local playerInput = require('classes.player.input')

local Player = GameObject:extend()

function Player:new(x, y, playerIndex, gameConfig)
	Player.super.new(self, x or 300, y or 300, gameConfig)

	self.playerIndex = playerIndex
	self.speed = playerConfig.move_speed
	self.scale = 32/20

	self.aimX = self.x
	self.aimY = self.y

	return self
end


function Player:update(dt)
	self:handleMovement(dt)
	self:updateAim()
end


function Player:handleMovement(dt)
	local moveInputX, moveInputY = playerInput.getMovementVector(playerConfig, self.playerIndex);

	self.x = self.x + moveInputX * self.speed * dt
	self.y = self.y + moveInputY * self.speed * dt
end

function Player:updateAim()
	local aimInputX, aimInputY, aimInputDistance = playerInput.getAimVector(playerConfig, self.playerIndex)

	local aimDistance =  aimInputDistance * playerConfig.crosshair_max_distance

	self.aimX = self.x + aimInputX * aimDistance
	self.aimY = self.y + aimInputY * aimDistance
end


return Player
