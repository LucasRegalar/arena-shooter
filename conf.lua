--- Love2D configuration — runs before the window is created.
-- Sets initial window properties that must be defined before love.load().
function love.conf(t)
	t.window.title = "Love Love Love"
	t.window.fullscreen = true
	t.window.fullscreentype = "desktop"
	t.window.icon = "assets/images/icon.png"
end
