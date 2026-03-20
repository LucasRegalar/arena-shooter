local Player = {}
Player.__index = Player

local SPRITE_SIZE = 20
local IDLE_ROW_Y = 20
-- skip the last to frames since idle has only 4 / 6
local IDLE_FRAME_TRIM = 2
local SPRITE_OFFSET_Y = 1
local MOVE_SPEED = 300
local GAMEPAD_DEADZONE = 0.2
local CROSSHAIR_MAX_DISTANCE = 60
local CROSSHAIR_RADIUS = 6
local CROSSHAIR_LINE = 10

function Player:new(x, y)
	local self = setmetatable({}, Player)
	self.x = x or 300
	self.y = y or 300
	self.speed = MOVE_SPEED
	self.scale = 3

	self.aimX = self.x
	self.aimY = self.y

	self.spriteSheet = love.graphics.newImage('sprites/NuclearLeak_CharacterAnim_1.2/character_20x20_pink.png')
	self.idleQuads = {}
	self.idleFrame = 1
	self.idleFrameTime = 0.15
	self.idleTimer = 0

	local spriteSheetWidth, spriteSheetHeight = self.spriteSheet:getDimensions()
	for i = 0, (spriteSheetWidth / SPRITE_SIZE) - 1 - IDLE_FRAME_TRIM do
		self.idleQuads[i + 1] = love.graphics.newQuad(
			i * SPRITE_SIZE,
			IDLE_ROW_Y,
			SPRITE_SIZE,
			SPRITE_SIZE,
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
	local originX = SPRITE_SIZE / 2 -- center of sprite
	local originY = SPRITE_SIZE / 2 -- center of sprite
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
	local boundsSize = SPRITE_SIZE * self.scale
	local boundsCenterX = boundsX + boundsSize / 2
	local boundsCenterY = boundsY + boundsSize / 2
	local visualOffsetY = SPRITE_OFFSET_Y * self.scale

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
	love.graphics.circle("line", self.aimX, self.aimY, CROSSHAIR_RADIUS)
	love.graphics.line(self.aimX - CROSSHAIR_LINE, self.aimY, self.aimX + CROSSHAIR_LINE, self.aimY)
	love.graphics.line(self.aimX, self.aimY - CROSSHAIR_LINE, self.aimX, self.aimY + CROSSHAIR_LINE)
end


function Player:handleMovement(dt)
	local moveX, moveY = 0, 0

	if love.keyboard.isDown("o") then
		moveX = moveX + 1
	end
	if love.keyboard.isDown("8") then
		moveY = moveY - 1
	end
	if love.keyboard.isDown("i") then
		moveY = moveY + 1
	end
	if love.keyboard.isDown("u") then
		moveX = moveX - 1
	end

	local joysticks = love.joystick.getJoysticks()
	local gamepad = joysticks[1]

	if gamepad then
		local stickX = gamepad:getGamepadAxis("leftx")
		local stickY = gamepad:getGamepadAxis("lefty")

		if math.abs(stickX) >= GAMEPAD_DEADZONE then
			moveX = moveX + stickX
		end

		if math.abs(stickY) >= GAMEPAD_DEADZONE then
			-- this has to be - y or the controls feel inverted
			moveY = moveY - stickY
		end
	end

	local magnitude = math.sqrt(moveX * moveX + moveY * moveY)
	if magnitude > 1 then
		moveX = moveX / magnitude
		moveY = moveY / magnitude
	end

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

	if magnitude < GAMEPAD_DEADZONE then
		self.aimX = self.x
		self.aimY = self.y
		return
	end

	local normalizedMagnitude = (magnitude - GAMEPAD_DEADZONE) / (1 - GAMEPAD_DEADZONE)
	if normalizedMagnitude > 1 then
		normalizedMagnitude = 1
	end

	local directionX = aimX / magnitude
	local directionY = aimY / magnitude
	local distance = normalizedMagnitude * CROSSHAIR_MAX_DISTANCE

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
