local Player = {}
Player.__index = Player

local playerConfig = require('classes.player.config')
local playerInput = require('classes.player.input')

function Player:new(x, y)
	local self = setmetatable({}, Player)
	self.x = x or 300
	self.y = y or 300
	self.speed = playerConfig.move_speed
	self.scale = 3

	self.aimX = self.x
	self.aimY = self.y

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


function Player:update(dt)
	self:handleMovement(dt)
	self:updateAim()
	self:updateAnimation(dt)
end


function Player:draw()
	local originX = playerConfig.sprite_size / 2 -- center of sprite
	local originY = playerConfig.sprite_size / 2 -- center of sprite
	-- todo: change this to only self.x ?
	-- These are the world coordinates you pass into love.graphics.draw.
	-- Because you also use an origin, these are not the final top-left corner.
	-- They are:
	-- - the screen position where the sprite’s origin/pivot should go
	-- So conceptually:
	-- - drawX/drawY = “where should the pivot land in the world?”
	local drawX = self.x -- - SPRITE_SIZE
	local drawY = self.y -- - SPRITE_SIZE
	-- bounds = sprite rectangle ater scaling
	local boundsX = drawX - originX * self.scale -- boundsX/boundsY = “where is the sprite’s real top-left after scaling and origin are applied?”
	local boundsY = drawY - originY * self.scale
	local boundsSize = playerConfig.sprite_size * self.scale
	local boundsCenterX = boundsX + boundsSize / 2
	local boundsCenterY = boundsY + boundsSize / 2
	local visualOffsetY = playerConfig.sprite_offset_y * self.scale

	love.graphics.draw(
		self.spriteSheet, -- A Texture (Image or Canvas) to texture the Quad with
		self.idleQuads[self.idleFrame], -- the quad to draw
		drawX, -- y to draw the object
		drawY - visualOffsetY, -- x to draw the object
		0, -- orientation = rotation?
		self.scale, -- scale factor x
		self.scale, -- scale factor y
		originX,
		originY
	)

	love.graphics.setColor(0, 1, 0) -- rgp green
	love.graphics.rectangle("line", boundsX, boundsY, boundsSize, boundsSize)

	love.graphics.setColor(1, 0, 0) -- rgp red
	love.graphics.circle("fill", self.x, self.y, 3)

	love.graphics.setColor(0, 0.8, 1) -- cyan
	love.graphics.circle("fill", boundsCenterX, boundsCenterY, 3)

	love.graphics.setColor(1, 1, 0) -- yellow
	love.graphics.circle("fill", boundsX, boundsY, 2)

	love.graphics.setColor(1, 1, 1) -- white
end

function Player:drawAim()
	love.graphics.circle("line", self.aimX, self.aimY, playerConfig.crosshair_radius)
	love.graphics.line(self.aimX - playerConfig.crosshair_line, self.aimY, self.aimX + playerConfig.crosshair_line, self.aimY)
	love.graphics.line(self.aimX, self.aimY - playerConfig.crosshair_line, self.aimX, self.aimY + playerConfig.crosshair_line)
end


function Player:handleMovement(dt)
	local moveX, moveY = playerInput.getMovementVector(playerConfig);

	self.x = self.x + moveX * self.speed * dt
	self.y = self.y + moveY * self.speed * dt
end

function Player:updateAim()
	local joysticks = love.joystick.getJoysticks()
	local gamepad = joysticks[1]

	if not gamepad then
		self.aimX = self.x
		self.aimY = self.y
		return
	end

	local aimX = gamepad:getGamepadAxis("rightx")
	local aimY = gamepad:getGamepadAxis("righty")
	local magnitude = math.sqrt(aimX * aimX + aimY * aimY)

	if magnitude < playerConfig.gamepad_deadzone then
		self.aimX = self.x
		self.aimY = self.y
		return
	end

	local normalizedMagnitude = (magnitude - playerConfig.gamepad_deadzone) / (1 - playerConfig.gamepad_deadzone)
	if normalizedMagnitude > 1 then
		normalizedMagnitude = 1
	end

	local directionX = aimX / magnitude
	local directionY = aimY / magnitude
	local distance = normalizedMagnitude * playerConfig.crosshair_max_distance

	self.aimX = self.x + directionX * distance
	-- this has to be - y or the controls feel inverted
	self.aimY = self.y - directionY * distance
end


function Player:updateAnimation(dt)
	self.idleTimer = self.idleTimer + dt
	if self.idleTimer >= self.idleFrameTime then
		self.idleTimer = self.idleTimer - self.idleFrameTime
		self.idleFrame = self.idleFrame % #self.idleQuads + 1
	end
end

return Player
