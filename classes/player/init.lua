local GameObject = require('classes.gameObject')

local playerConfig = require('classes.player.config')
local playerInput = require('classes.player.input')

local Player = GameObject:extend()

function Player:new(x, y, playerIndex, gameConfig)
	Player.super.new(self, x or 300, y or 300, gameConfig)

	self.playerIndex = playerIndex
	self.speed = playerConfig.move_speed
	self.scale = 32/20
	self.isFacingLeft = false

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

--- Updates player state each frame.
--- @param dt number Delta time since the last frame
--- @param viewport Viewport The viewport for mouse aim screen-to-world conversion
function Player:update(dt, viewport)
	self:updateAim(viewport)
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

--- Updates the player's aim direction, hand position, and crosshair position.
-- Reads gamepad aim first; if the gamepad has no input, falls back to mouse aim.
-- This preserves gamepad priority for players using controllers.
--- @param viewport Viewport The viewport for mouse aim screen-to-world conversion
function Player:updateAim(viewport)
	local aimInputX, aimInputY, aimInputDistance = playerInput.getAimVector(playerConfig, self.playerIndex)

	-- Fall back to mouse aim when gamepad has no input
	if aimInputDistance == 0 then
		aimInputX, aimInputY, aimInputDistance = playerInput.getMouseAimVector(
			self.x, self.y, viewport, playerConfig
		)
	end

	local handDistance = playerConfig.hand_distance
	local aimDistance = aimInputDistance * playerConfig.crosshair_max_distance

	if aimDistance > 0 then
		self.aimDirectionX = aimInputX
		self.aimDirectionY = aimInputY
		self.isFacingLeft = aimInputX < 0
	end

	self.handX = self.x - self.aimDirectionY * handDistance
	self.handY = self.y + math.abs(self.aimDirectionX) * handDistance

	self.crossHairX = self.x + aimInputX * aimDistance
	self.crossHairY = self.y + aimInputY * aimDistance
end


return Player
