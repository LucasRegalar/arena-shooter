Player = {}
Player.__index = Player

function Player:new(x, y)
	local self = setmetatable({}, Player)
	self.x = x or 300
	self.y = y or 300
	self.speed = 3
	self.scale = 3

	self.spriteSheet = love.graphics.newImage('sprites/NuclearLeak_CharacterAnim_1.2/character_20x20_pink.png')
	self.idleQuads = {}
	self.idleFrame = 1
	self.idleFrameTime = 0.15
	self.idleTimer = 0

	local spriteSheetWidth, spriteSheetHeight = self.spriteSheet:getDimensions()
	-- -2 becuase idle animation has less quads then full spriteSheet length
	for i = 0, (spriteSheetWidth / 20) - 1 - 2 do
		self.idleQuads[i + 1] = love.graphics.newQuad(i * 20, 20, 20, 20, spriteSheetWidth, spriteSheetHeight)
	end

	return self
end

function Player:update(dt)
	self:handleMovement()
	self:handleGamepad(dt)
	self:updateAnimation(dt)
end

function Player:draw()
	love.graphics.draw(
		self.spriteSheet,
		self.idleQuads[self.idleFrame],
		self.x - 20,
		self.y - 20,
		0,
		self.scale,
		self.scale
	)
end

-- legacy to keep testabilty with keyboard
function Player:handleMovement()
	if love.keyboard.isDown("o") then
		self.x = self.x + self.speed
	end
	if love.keyboard.isDown("8") then
		self.y = self.y - self.speed
	end
	if love.keyboard.isDown("i") then
		self.y = self.y + self.speed
	end
	if love.keyboard.isDown("u") then
		self.x = self.x - self.speed
	end
end

-- gamepad controls
function Player:handleGamepad(dt)
	local joysticks = love.joystick.getJoysticks()
	local gamepad = joysticks[1]

	if not gamepad then
		return
	end

	local moveX = gamepad:getGamepadAxis("leftx")
	local moveY = gamepad:getGamepadAxis("lefty")
	local deadzone = 0.2

	if math.abs(moveX) < deadzone then
		moveX = 0
	end

	if math.abs(moveY) < deadzone then
		moveY = 0
	end

	self.x = self.x + moveX * self.speed * dt * 100
	self.y = self.y - moveY * self.speed * dt * 100
end

function Player:updateAnimation(dt)
	self.idleTimer = self.idleTimer + dt
	if self.idleTimer >= self.idleFrameTime then
		self.idleTimer = self.idleTimer - self.idleFrameTime
		self.idleFrame = self.idleFrame % #self.idleQuads + 1
	end
end

return Player
