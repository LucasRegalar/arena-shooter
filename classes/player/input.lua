local input = {}

local function getGamepad(playerIndex)

	local joysticks = love.joystick.getJoysticks()
	local gamepad = joysticks[playerIndex]

	return gamepad;
end

function input.getMovementVector(config, playerIndex)

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

	local gamepad = getGamepad(playerIndex)

	if gamepad then
		local stickX = gamepad:getGamepadAxis("leftx")
		-- this has to be - y or the controls feel inverted
		local stickY = - gamepad:getGamepadAxis("lefty")

		if math.abs(stickX) >= config.gamepad_deadzone then
			moveX = moveX + stickX
		end

		if math.abs(stickY) >= config.gamepad_deadzone then
			moveY = moveY + stickY
		end
	end

	local magnitude = math.sqrt(moveX * moveX + moveY * moveY)
	if magnitude > 1 then
		moveX = moveX / magnitude
		moveY = moveY / magnitude
	end

	return moveX, moveY
end

function input.getAimVector(config, playerIndex)

	local directionX = 0
	local directionY = 0
	local distance = 0

	local gamepad = getGamepad(playerIndex)

	if not gamepad then

		return directionX, directionY, distance
	end

	local aimX = gamepad:getGamepadAxis("rightx")
	-- this has to be - y or the controls feel inverted
	local aimY = - gamepad:getGamepadAxis("righty")
	local magnitude = math.sqrt(aimX * aimX + aimY * aimY)

	if magnitude < config.gamepad_deadzone then

		return directionX, directionY, distance

	end

	-- This makes aiming distance begin smoothly after the deadzone instead of jumping.
	local normalizedMagnitude = (magnitude - config.gamepad_deadzone) / (1 - config.gamepad_deadzone)
	-- safty clamp to have max 1 magnitude. Just in case
	if normalizedMagnitude > 1 then
		normalizedMagnitude = 1
	end

	-- convert raw stick vector into pure direction vector
	directionX = aimX / magnitude
	-- convert raw stick vector into pure direction vector
	directionY = aimY / magnitude
	distance = normalizedMagnitude

	return directionX, directionY, distance
end

return input

