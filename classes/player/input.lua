-- - input.lua should only deal with reading controls and returning values
--  - it should not know how to animate or draw the player

local input = {}

function input.getMovementVector(config)

	local moveX, moveY = 0, 0

	if love.keyboard.isDown("o") or love.keyboard.isDown("d")  then
		moveX = moveX + 1
	end
	if love.keyboard.isDown("8") or love.keyboard.isDown("w") then
		moveY = moveY - 1
	end
	if love.keyboard.isDown("i") or love.keyboard.isDown("s") then
		moveY = moveY + 1
	end
	if love.keyboard.isDown("u") or love.keyboard.isDown("a") then
		moveX = moveX - 1
	end

	local joysticks = love.joystick.getJoysticks()
	local gamepad = joysticks[1]

	if gamepad then
		local stickX = gamepad:getGamepadAxis("leftx")
		local stickY = gamepad:getGamepadAxis("lefty")

		if math.abs(stickX) >= config.gamepad_deadzone then
			moveX = moveX + stickX
		end

		if math.abs(stickY) >= config.gamepad_deadzone then
			-- this has to be - y or the controls feel inverted
			moveY = moveY - stickY
		end
	end

	local magnitude = math.sqrt(moveX * moveX + moveY * moveY)
	if magnitude > 1 then
		moveX = moveX / magnitude
		moveY = moveY / magnitude
	end

	return moveX, moveY
end

return input

