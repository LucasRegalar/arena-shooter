local GameObject = require('classes.gameObject')

local playerConfig = require('classes.player.config')
local playerInput = require('classes.player.input')

local Player = GameObject:extend()

function Player:new(x, y, playerIndex, gameConfig)
	Player.super.new(self, x or 300, y or 300, gameConfig)

	self.playerIndex = playerIndex
	self.speed = playerConfig.move_speed
	self.scale = 32/20

	self.crossHairX = self.x
	self.crossHairY = self.y

	self.aimDirectionX = 1
	self.aimDirectionY = 0

	self.handX = self.x - playerConfig.hand_distance
	self.handY = self.y - playerConfig.hand_distance

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
	local handDistance = playerConfig.hand_distance
	local aimDistance =  aimInputDistance * playerConfig.crosshair_max_distance

	-- if aimInputX * aimInputX + aimInputY * aimInputY > 0 then
	if aimDistance > 0 then
		self.aimDirectionX = aimInputX
		self.aimDirectionY = aimInputY
		self.handX = self.x - aimInputY * handDistance
		self.handY = self.y + aimInputX * handDistance
	end

	self.crossHairX = self.x + aimInputX * aimDistance
	self.crossHairY = self.y + aimInputY * aimDistance
end


return Player
