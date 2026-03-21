--- Configuration constants for the projectile system.
-- Defines bullet behavior, collision size, range, and fire rate.
-- Range and speed will eventually vary per weapon type.
local projectileConfig = {
	--- Movement speed in pixels per second.
	speed = 800,

	--- Side length of the square collision hitbox in pixels.
	size = 6,

	--- Maximum travel distance in pixels before the projectile is destroyed.
	-- Maps to weapon range — future weapons will override this value.
	max_range = 600,

	--- Minimum seconds between consecutive shots.
	fire_rate = 0.15,

	--- Gamepad button that triggers firing.
	fire_gamepad_button = "rightshoulder",
}

return projectileConfig
