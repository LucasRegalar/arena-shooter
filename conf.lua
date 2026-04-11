--- Love2D configuration — runs before the window is created.
-- Sets initial window properties that must be defined before love.load().
-- Fullscreen is managed by push.lua in love.load(), not here.
function love.conf(t)
	t.window.title = "Love Love Love"
	t.window.icon = "assets/images/icon.png"
end
