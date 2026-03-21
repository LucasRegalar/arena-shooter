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


--- Half-width of the player's collision hitbox in pixels.
-- The full hitbox is 28x28, slightly smaller than a 32px tile for forgiving navigation.
Player.halfWidth = 14

--- Half-height of the player's collision hitbox in pixels.
Player.halfHeight = 14

function Player:update(dt)
	self:updateAim()
end

--- Returns the player's desired movement delta for this frame.
-- Does not apply the movement — the Game orchestrator resolves collision first.
--- @param dt number Delta time since the last frame
--- @return number dx Desired horizontal movement in pixels
--- @return number dy Desired vertical movement in pixels
function Player:getMovementDelta(dt)
	local moveInputX, moveInputY = playerInput.getMovementVector(playerConfig, self.playerIndex)
	return moveInputX * self.speed * dt, moveInputY * self.speed * dt
end

function Player:updateAim()
	local aimInputX, aimInputY, aimInputDistance = playerInput.getAimVector(playerConfig, self.playerIndex)
	local handDistance = playerConfig.hand_distance
	local aimDistance = aimInputDistance * playerConfig.crosshair_max_distance

	-- if aimInputX * aimInputX + aimInputY * aimInputY > 0 then
	if aimDistance > 0 then
		self.aimDirectionX = aimInputX
		self.aimDirectionY = aimInputY
	end

	self.handX = self.x - self.aimDirectionX * handDistance
	self.handY = self.y + self.aimDirectionY * handDistance

	self.crossHairX = self.x + aimInputX * aimDistance
	self.crossHairY = self.y + aimInputY * aimDistance
end


return Player
