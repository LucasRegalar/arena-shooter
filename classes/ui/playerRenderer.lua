local PlayerRenderer = Object:extend()
local anim8 = require('lib.anim8')

local gameConfig = require('classes.game.config')


function PlayerRenderer:new(player, playerConfig)
	self.player = player
	self.playerConfig = playerConfig

	self.originX = self.playerConfig.sprite_size / 2 -- center of sprite
	self.originY = self.playerConfig.sprite_size / 2 -- center of sprite

	self.spriteSheet = love.graphics.newImage('assets/sprites/characters/pink.png')

	local spriteSheetWidth, spriteSheetHeight = self.spriteSheet:getDimensions()

	local grid = anim8.newGrid(
		self.playerConfig.sprite_size,
		self.playerConfig.sprite_size,
		spriteSheetWidth,
		spriteSheetHeight
	)

	self.animation = anim8.newAnimation(grid('1-4', 2), 0.25)

	return self
end


function PlayerRenderer:draw()
	local renderData = self:getRenderData()
	self:drawPlayer(renderData)
	self:drawAim()
	if gameConfig.debug then
		self:drawDebug(renderData)
	end
end


function PlayerRenderer:getRenderData()
	local drawX = self.player.x
	local drawY = self.player.y
	-- bounds = sprite rectangle ater scaling
	local boundsX = drawX - self.originX * self.player.scale -- boundsX/boundsY = “where is the sprite’s real top-left after scaling and origin are applied?”
	local boundsY = drawY - self.originY * self.player.scale
	local boundsSize = self.playerConfig.sprite_size * self.player.scale
	local boundsCenterX = boundsX + boundsSize / 2
	local boundsCenterY = boundsY + boundsSize / 2
	local visualOffsetY = self.playerConfig.sprite_offset_y * self.player.scale

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


function PlayerRenderer:update(dt)
	self.animation:update(dt)
end


function PlayerRenderer:drawPlayer(renderData)
	local scaleX = self.player.isFacingLeft and -self.player.scale or self.player.scale

	self.animation:draw(
		self.spriteSheet,
		renderData.drawX,
		renderData.drawY - renderData.visualOffsetY,
		0,
		scaleX,
		self.player.scale,
		self.originX,
		self.originY
	)
end


function PlayerRenderer:drawDebug(renderData)
	love.graphics.setColor(0, 1, 0) -- rgp green
	love.graphics.rectangle("line", renderData.boundsX, renderData.boundsY, renderData.boundsSize, renderData.boundsSize)

	love.graphics.setColor(1, 0, 0) -- rgp red
	love.graphics.circle("fill", self.player.x, self.player.y, 3)

	love.graphics.setColor(0, 0.8, 1) -- cyan
	love.graphics.circle("fill", renderData.boundsCenterX, renderData.boundsCenterY, 3)

	love.graphics.setColor(1, 1, 0) -- yellow
	love.graphics.circle("fill", renderData.boundsX, renderData.boundsY, 2)

	love.graphics.setColor(1, 1, 1) -- white
end


function PlayerRenderer:drawAim()
	love.graphics.circle("line", self.player.crossHairX, self.player.crossHairY, self.playerConfig.crosshair_radius)
	love.graphics.line(self.player.crossHairX - self.playerConfig.crosshair_line, self.player.crossHairY, self.player.crossHairX + self.playerConfig.crosshair_line, self.player.crossHairY)
	love.graphics.line(self.player.crossHairX, self.player.crossHairY - self.playerConfig.crosshair_line, self.player.crossHairX, self.player.crossHairY + self.playerConfig.crosshair_line)
end

return PlayerRenderer
