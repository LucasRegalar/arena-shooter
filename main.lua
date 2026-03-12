function love.load()
	-- important for pixel art
	love.graphics.setDefaultFilter("nearest", "nearest")
	Player = {}
	Player.x = 300
	Player.y = 300
	Player.speed = 3
	Player.sprite = love.graphics.newImage('sprites/parrot.png')
	Player.idleSpriteSheet = love.graphics.newImage('sprites/NuclearLeak_CharacterAnim_1.2/character_20x20_pink.png')
	Player.idleQuads = {}
	Player.idleFrame = 1
	Player.idleFrameTime = 0.15
	Player.idleTimer = 0
	Player.scale = 4

	local spriteSheetWidth, spriteSheetHeight = Player.idleSpriteSheet:getDimensions()
	for i = 0, (spriteSheetWidth / 20) - 1 - 2 do
		Player.idleQuads[i + 1] = love.graphics.newQuad(i * 20, 20, 20, 20, spriteSheetWidth, spriteSheetHeight)
	end

	Background = {}
	Background.sprite = love.graphics.newImage('sprites/background.png')
end

function love.update(dt)
	Player.idleTimer = Player.idleTimer + dt
	if Player.idleTimer >= Player.idleFrameTime then
		Player.idleTimer = Player.idleTimer - Player.idleFrameTime
		Player.idleFrame = Player.idleFrame % #Player.idleQuads + 1
	end

	if love.keyboard.isDown("\\") then
		Player.x = Player.x + Player.speed
	end
	if love.keyboard.isDown("0") then
		Player.y = Player.y - Player.speed
	end
	if love.keyboard.isDown("p") then
		Player.y = Player.y + Player.speed
	end
	if love.keyboard.isDown("o") then
		Player.x = Player.x - Player.speed
	end
end

function love.draw()
	-- love.graphics.draw(Background.sprite, 0, 0)
	-- love.graphics.draw(Player.sprite, Player.x, Player.y)
	love.graphics.draw(Player.idleSpriteSheet, Player.idleQuads[Player.idleFrame], Player.x - 20, Player.y - 20, 0, Player.scale, Player.scale)
end
