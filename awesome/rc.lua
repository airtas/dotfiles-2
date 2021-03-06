pcall(require, "luarocks.loader")
local awful = require("awful")
local beautiful = require("beautiful")
-- register naughty error reporter
require("components.reporter")

-- setup global(rc) variables for later usage
conf = {
  aw_root = awful.util.getdir("config"),
  app = {
    editor = "code",
    term = "urxvt",
    launcher = "rofi -show run",
    screenshot = "chiisu",
    logout = "clearine"
  }
}

-- invoke xdg autostart ()
if not conf.awesome_started then
  awful.spawn("dex --autostart --environment Awesome", false)
  conf.awesome_started = true
end

-- initialize theme system and pywal
local pywal = require("components.pywal")
pywal.restore()
local current_theme = conf.aw_root.."/themes/default/theme.lua"
beautiful.init(current_theme)

local bindings = require("components.bindings")
local menuschema = require("components.menuschema")
local panel = require("components.panel")

-- setup menu with menuschema
conf.menu = awful.menu(menuschema)

-- setup window rules and layouts
awful.rules.rules = require("components.windowrules")
awful.layout.layouts = {
  awful.layout.suit.floating,
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
  awful.layout.suit.max.fullscreen,
  awful.layout.suit.max,
}

-- register hotkeys and mouse
root.keys(bindings.keys)
root.buttons(bindings.mouse)

-- set waallpaper with pywal
awful.screen.connect_for_each_screen(function()
  pywal.set_wallpaper()
end)

-- register client signals
require("components.clientsignal")

--reload compton on every wallpaper changed
awesome.connect_signal("wallpaper_changed", function()
  awful.spawn.with_shell("pkill compton; compton")
end)

-- custom signal for pywal
awesome.connect_signal("pywal::apply", function()
  package.loaded["components.pywal"] = nil
  pywal = require("components.pywal")
  pywal.set_wallpaper()
  beautiful.init(current_theme)
end)
