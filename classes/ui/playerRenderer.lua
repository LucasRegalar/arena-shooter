local PlayerRenderer = Object:extend()

function PlayerRenderer:new(player, playerConfig)
	self.player = player
	self.playerConfig = playerConfig

	self.originX = self.playerConfig.sprite_size / 2 -- center of sprite
	self.originY = self.playerConfig.sprite_size / 2 -- center of sprite

	self.spriteSheet = love.graphics.newImage('sprites/NuclearLeak_CharacterAnim_1.2/character_20x20_pink.png')
	self.idleQuads = {}
	self.idleFrame = 1
	self.idleFrameTime = 0.15
	self.idleTimer = 0

	local spriteSheetWidth, spriteSheetHeight = self.spriteSheet:getDimensions()
	for i = 0, (spriteSheetWidth / playerConfig.sprite_size) - 1 - playerConfig.idle_frame_trim do
		self.idleQuads[i + 1] = love.graphics.newQuad(
			i * playerConfig.sprite_size,
			playerConfig.idle_row_y,
			playerConfig.sprite_size,
			playerConfig.sprite_size,
			spriteSheetWidth,
			spriteSheetHeight
		)
	end

	return self
end

function PlayerRenderer:draw()
	local renderData = self:getRenderData()
	self:drawPlayer(renderData)
	self:drawAim()
	self:drawDebug(renderData)
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
	self.idleTimer = self.idleTimer + dt
	if self.idleTimer >= self.idleFrameTime then
		self.idleTimer = self.idleTimer - self.idleFrameTime
		self.idleFrame = self.idleFrame % #self.idleQuads + 1
	end
end


function PlayerRenderer:drawPlayer(renderData)
	love.graphics.draw(
		self.spriteSheet, -- A Texture (Image or Canvas) to texture the Quad with
		self.idleQuads[self.idleFrame], -- the quad to draw
		renderData.drawX, -- y to draw the object
		renderData.drawY - renderData.visualOffsetY, -- x to draw the object
		0, -- orientation = rotation?
		self.player.scale, -- scale factor x
		self.player.scale, -- scale factor y
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

--- Draws the player's world-space aim indicator.
-- Uses the player model's current aim target so the crosshair stays aligned
-- with gameplay input.
function PlayerRenderer:drawAim()
	love.graphics.circle("line", self.player.aimX, self.player.aimY, self.playerConfig.crosshair_radius)
	love.graphics.line(self.player.aimX - self.playerConfig.crosshair_line, self.player.aimY, self.player.aimX + self.playerConfig.crosshair_line, self.player.aimY)
	love.graphics.line(self.player.aimX, self.player.aimY - self.playerConfig.crosshair_line, self.player.aimX, self.player.aimY + self.playerConfig.crosshair_line)
end

return PlayerRenderer
