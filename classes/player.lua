local Player = {}
Player.__index = Player

local SPRITE_SIZE = 20
local IDLE_ROW_Y = 20
local IDLE_FRAME_TRIM = 2
local MOVE_SPEED = 300
local GAMEPAD_DEADZONE = 0.2

function Player:new(x, y)
	local self = setmetatable({}, Player)
	self.x = x or 300
	self.y = y or 300
	self.speed = MOVE_SPEED
	self.scale = 3

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
	self:updateAnimation(dt)
end


function Player:draw()
	love.graphics.draw(
		self.spriteSheet,
		self.idleQuads[self.idleFrame],
		self.x - SPRITE_SIZE,
		self.y - SPRITE_SIZE,
		0,
		self.scale,
		self.scale
	)
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


function Player:updateAnimation(dt)
	self.idleTimer = self.idleTimer + dt
	if self.idleTimer >= self.idleFrameTime then
		self.idleTimer = self.idleTimer - self.idleFrameTime
		self.idleFrame = self.idleFrame % #self.idleQuads + 1
	end
end

return Player
