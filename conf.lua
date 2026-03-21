--- Love2D configuration — runs before the window is created.
-- Sets initial window properties that must be defined before love.load().
function love.conf(t)
	t.window.title = "T-DAS 3000"
	t.window.fullscreen = true
	t.window.fullscreentype = "desktop"
	t.window.icon = "sprites/icon.png"
end
