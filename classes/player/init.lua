local Object = require('lib.classic')
local anim8 = require('lib.anim8')

local gameConfig = require('config')
local playerConfig = require('classes.player.config')
local playerInput = require('classes.player.input')

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

	self.originX = playerConfig.sprite_size / 2 -- center of sprite
	self.originY = playerConfig.sprite_size / 2 -- center of sprite

	self.spriteSheet = love.graphics.newImage('sprites/character/character_20x20_pink.png')

	local spriteSheetWidth, spriteSheetHeight = self.spriteSheet:getDimensions()

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

-- todo: extract into render file
function Player:draw()
	local renderData = self:getRenderData()
	self:drawPlayer(renderData)
	self:drawAim()
	if gameConfig.debug then
		self:drawDebug(renderData)
	end
end

function Player:drawPlayer(renderData)
	local scaleX = self.isFacingLeft and -self.scale or self.scale

	self.animation:draw(
		self.spriteSheet,
		renderData.drawX,
		renderData.drawY - renderData.visualOffsetY,
		0,
		scaleX,
		self.scale,
		self.originX,
		self.originY
	)
end


function Player:drawDebug(renderData)
	love.graphics.setColor(0, 1, 0) -- rgp green
	love.graphics.rectangle("line", renderData.boundsX, renderData.boundsY, renderData.boundsSize, renderData.boundsSize)

	love.graphics.setColor(1, 0, 0) -- rgp red
	love.graphics.circle("fill", self.x, self.y, 3)

	love.graphics.setColor(0, 0.8, 1) -- cyan
	love.graphics.circle("fill", renderData.boundsCenterX, renderData.boundsCenterY, 3)

	love.graphics.setColor(1, 1, 0) -- yellow
	love.graphics.circle("fill", renderData.boundsX, renderData.boundsY, 2)

	love.graphics.setColor(1, 1, 1) -- white
end


function Player:drawAim()
	love.graphics.circle("line", self.crossHairX, self.crossHairY, playerConfig.crosshair_radius)
	love.graphics.line(self.crossHairX - playerConfig.crosshair_line, self.crossHairY, self.crossHairX + playerConfig.crosshair_line, self.crossHairY)
	love.graphics.line(self.crossHairX, self.crossHairY - playerConfig.crosshair_line, self.crossHairX, self.crossHairY + playerConfig.crosshair_line)
end

function Player:getRenderData()
	local drawX = self.x
	local drawY = self.y
	-- bounds = sprite rectangle ater scaling
	local boundsX = drawX - self.originX * self.scale -- boundsX/boundsY = “where is the sprite’s real top-left after scaling and origin are applied?”
	local boundsY = drawY - self.originY * self.scale
	local boundsSize = playerConfig.sprite_size * self.scale
	local boundsCenterX = boundsX + boundsSize / 2
	local boundsCenterY = boundsY + boundsSize / 2
	local visualOffsetY = playerConfig.sprite_offset_y * self.scale

	return {
		drawX = drawX,
		drawY = drawY,
		boundsX = boundsX,
		boundsY = boundsY,
		boundsSize = boundsSize,
		boundsCenterX = boundsCenterX,
		boundsCenterY = boundsCenterY,
		visualOffsetY = visualOffsetY
	}
end


return Player
