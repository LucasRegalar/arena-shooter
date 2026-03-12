function love.load()
	Player = {}
	Player.x = 300
	Player.y = 300
	Player.speed = 3
	Player.sprite = love.graphics.newImage('sprites/parrot.png')

	Background = {}
	Background.sprite = love.graphics.newImage('sprites/background.png')
end

function love.update()
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
	love.graphics.circle('fill', Player.x, Player.y, 10)
end
