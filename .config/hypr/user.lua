-- --- hypr/user.lua --------------------------------------------------------
-- Your Hyprland overrides, in Ryoku's `hl` Lua API. Loaded LAST, so anything
-- here wins over Ryoku's defaults and over Ryoku Settings. Updates never touch
-- it. Reach for it only for raw config the GUI does not expose.
--
-- --- who owns what --------------------------------------------------------
--   Ryoku defaults   the base modules           replaced by updates   don't edit
--   Ryoku Settings   settings.lua, rebinds.lua  the GUI writes these  edit in-app
--   you              this file, + anything you drop in user_edits     yours
--
-- --- take over a whole module ---------------------------------------------
-- Copy it into the overlay at the same path and edit there, e.g.
--   ~/.config/ryoku/user_edits/hypr/modules/binds.lua
-- You then own that file: `ryoku doctor` warns when an update changes the
-- original, and `ryoku reset hypr/modules/binds.lua` hands it back.
--
hl.config({ general = { border_size = 1 } })

hl.config({
  input = {
    touchpad = { natural_scroll = true }
  }
})

hl.env("BROWSER", "helium-browser")

hl.window_rule({ match = { class = "org.gnome.Nautilus" }, float = true, size = { 1000, 500 } })
hl.window_rule({ match = { class = "com.gabm.satty" }, float = true, size = { 1500, 800 } })
hl.window_rule({ match = { class = "mpv" }, float = true, size = { 1500, 800 } })

local mod = "SUPER"
local ok, rebinds = pcall(require, "rebinds")
if not ok or type(rebinds) ~= "table" then rebinds = {} end
local function K(k) return rebinds[k] or k end
local ws_helper = (os.getenv("HOME") or "") .. "/.config/hypr/scripts/ryoku-workspace"

for i = 1, 10 do
  local key = i % 10
  hl.bind(K(mod .. " + SHIFT + " .. key), hl.dsp.exec_cmd(ws_helper .. " move " .. i))
end

hl.bind(K(mod .. "" .. " + A"),
  function()
    hl.dispatch(hl.dsp.window.float({ action = "toggle" }));
    hl.dispatch(hl.dsp.window.resize({ x = 1300, y = 700, exact = true }));
    hl.dispatch(hl.dsp.window.center())
  end)

hl.bind(K(mod .. " + SHIFT + H"), hl.dsp.window.move({ workspace = "special:scratch", silent = true }))
hl.bind(K(mod .. " + H"), hl.dsp.workspace.toggle_special("scratch"))
hl.bind(K(mod .. " + SHIFT + J"), hl.dsp.window.move({ workspace = "special:music", silent = true }))
hl.bind(K(mod .. " + J"), hl.dsp.workspace.toggle_special("music"))
hl.bind(mod .. " + D", hl.dsp.window.fullscreen_state({ internal = 2, client = 0, action = "toggle", }))
hl.bind(K("ALT + Tab"), hl.dsp.window.cycle_next())
