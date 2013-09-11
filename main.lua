heroesfw = {}

function love.load()
    heroesfw.start("readmap.lua")
end

function love.update(dt) end
function love.draw() end
function love.keypressed(k) end
function love.keyreleased(k) end
function love.mousepressed(x, y, b) end
function love.mousereleased(x, y, b) end

function heroesfw.keypressed(k)
    if k == "escape" then
        love.event.quit()
    end
end

function heroesfw.resume()
    load = nil
    love.update = heroesfw.update
    love.draw = heroesfw.draw
    love.keypressed = heroesfw.keypressed
    love.keyreleased = heroesfw.keyreleased
    love.mousepressed = heroesfw.mousepressed
    love.mousereleased = heroesfw.mousereleased

    love.mouse.setVisible(true)
end

function heroesfw.draw()
	love.graphics.print('Main Menu!', 400, 300)
end

function heroesfw.start(script)
    -- Clear all callbacks.
    love.load = heroesfw.empty
    love.update = heroesfw.empty
    love.draw = heroesfw.empty
    love.keypressed = heroesfw.empty
    love.keyreleased = heroesfw.empty
    love.mousepressed = heroesfw.empty
    love.mousereleased = heroesfw.empty

	love.filesystem.load(script)()
	-- Redirect keypress
	local o_keypressed = love.keypressed
	love.keypressed =
		function(k)
			if k == "escape" then
				heroesfw.resume()
			end
			o_keypressed(k)
		end
	love.load()
end

function heroesfw.empty() end
