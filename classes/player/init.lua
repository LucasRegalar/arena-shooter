local Object = require('lib.classic')
local anim8 = require('lib.anim8')

local gameConfig = require('config')
local playerConfig = require('classes.player.config')
local playerInput = require('classes.player.input')
local playerRender = require('classes.player.render')

local Player = Object:extend()

-- todo: refactor so player receives opts or config instead of
-- requirering the gameConfig
function Player:new(x, y, playerIndex)
	self.x = x
	self.y = y
	self.playerIndex = playerIndex
	self.speed = playerConfig.move_speed
	self.scale = 3
	self.isFacingLeft = false

	self.crossHairX = self.x
	self.crossHairY = self.y

	self.aimDirectionX = 1
	self.aimDirectionY = 0

	self.handX = self.x - playerConfig.hand_distance
	self.handY = self.y - playerConfig.hand_distance

	local spriteSheetWidth, spriteSheetHeight = playerConfig.sprite_sheet:getDimensions()

	local grid = anim8.newGrid(
		playerConfig.sprite_size,
		playerConfig.sprite_size,
		spriteSheetWidth,
		spriteSheetHeight
	)

	self.animation = anim8.newAnimation(grid('1-4', 2), 0.25)

	return self
end

function Player:update(dt)
	self:handleMovement(dt)
	self:updateAim()
	self.animation:update(dt)
end


function Player:handleMovement(dt)
	local moveInputX, moveInputY = playerInput.getMovementVector(playerConfig, self.playerIndex);

	self.x = self.x + moveInputX * self.speed * dt
	self.y = self.y + moveInputY * self.speed * dt
end


function Player:updateAim()
	local aimInputX, aimInputY, aimInputDistance = playerInput.getAimVector(playerConfig, self.playerIndex)

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

function Player:draw()
	playerRender.draw(
		self.x,
		self.y,
		self.crossHairX,
		self.crossHairY,
		self.isFacingLeft,
		self.animation
	)
end

return Player
