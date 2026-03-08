function love.load()
	Player = {}
	Player.x = 300
	Player.y = 300
end

function love.update()
	if love.keyboard.isDown("o") then
		Player.x = Player.x + 1
	end
	if love.keyboard.isDown("i") then
		Player.y = Player.y - 1
	end
	if love.keyboard.isDown("u") then
		Player.y = Player.y + 1
	end
	if love.keyboard.isDown("y") then
		Player.x = Player.x - 1
	end
end

function love.draw()
	love.graphics.circle('fill', Player.x, Player.y, 30)
end
