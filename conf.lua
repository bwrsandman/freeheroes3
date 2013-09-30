local love = love or {}
function love.conf(t)
    t.title = "Freeheroes3"     -- The title of the window the game is in (string)
    t.author = "Sandy Carter"   -- The author of the game (string)
                                -- The website of the game (string)
    t.url = "https://github.com/bwrsandman/freeheroes3"
    t.identity = nil            -- The name of the save directory (string)
    t.version = "0.8.0"         -- The LÖVE version this game was made for (string)
    t.console = false           -- Attach a console (boolean, Windows only)
    t.release = false           -- Enable release mode (boolean)
    t.screen.width = 800        -- The window width (number)
    t.screen.height = 600       -- The window height (number)
    t.screen.fullscreen = false -- Enable fullscreen (boolean)
    t.screen.vsync = true       -- Enable vertical sync (boolean)
    t.screen.fsaa = 0           -- The number of FSAA-buffers (number)
    t.modules.joystick = false  -- Enable the joystick module (boolean)
    t.modules.audio = true      -- Enable the audio module (boolean)
    t.modules.keyboard = true   -- Enable the keyboard module (boolean)
    t.modules.event = true      -- Enable the event module (boolean)
    t.modules.image = true      -- Enable the image module (boolean)
    t.modules.graphics = true   -- Enable the graphics module (boolean)
    t.modules.timer = true      -- Enable the timer module (boolean)
    t.modules.mouse = true      -- Enable the mouse module (boolean)
    t.modules.sound = true      -- Enable the sound module (boolean)
    t.modules.physics = false   -- Enable the physics module (boolean)
end

function h3map_conf(t)
    t.print.info = false
    t.print.players = false
    t.print.player.red = true
    t.print.player.blue = true
    t.print.player.tan = false
    t.print.player.green = false
    t.print.player.orange = false
    t.print.player.purple = false
    t.print.player.teal = false
    t.print.player.pink = false
    t.print.victory = false
    t.print.teams = true
    t.print.next = true
    t.print.offset = false
end

function h3mdesc_conf(t)
    t.printdescs = false
    t.prefix = "h3mdesc/"
    t.filenames = {
        "info",
        "player",
        "victory",
        "teams",
        "next",
    }
end
