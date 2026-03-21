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

function input.getAimVector(config)

	local directionX = 0
	local directionY = 0
	local distance = 0

	local joysticks = love.joystick.getJoysticks()
	local gamepad = joysticks[1]

	if not gamepad then

		return directionX, directionY, distance
	end

	local aimX = gamepad:getGamepadAxis("rightx")
	local aimY = gamepad:getGamepadAxis("righty")
	local magnitude = math.sqrt(aimX * aimX + aimY * aimY)

	if magnitude < config.gamepad_deadzone then

		return directionX, directionY, distance

	end

	local normalizedMagnitude = (magnitude - config.gamepad_deadzone) / (1 - config.gamepad_deadzone)
	if normalizedMagnitude > 1 then
		normalizedMagnitude = 1
	end

	directionX = aimX / magnitude
	directionY = aimY / magnitude
	distance = normalizedMagnitude * config.crosshair_max_distance

	return directionX, directionY, distance
end

return input

