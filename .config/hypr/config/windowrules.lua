hl.window_rule({ match = { float = true }, center = true, persistent_size = true })

local function float(match, size)
  hl.window_rule({
    match = match,
    float = true,
    center = true,
    size = size or { "monitor_w*0.70", "monitor_h*0.80" },
  })
end

float({ class = "^(org.gnome.Nautilus|org.kde.dolphin|org.gnome.Calculator|pkg-installer|mpv|org.satty.satty)$" })
float({ title = "^(sh|pkg installer)$" })

hl.window_rule({
  match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
  float = true,
  keep_aspect_ratio = true,
  size = { "monitor_w*0.25", "monitor_h*0.25" },
  pin = true,
})

float({ class = "^(dev\\.)?(noctalia\\.Noctalia(\\.Settings)?)$" }, { "monitor_w*0.70", "monitor_h*0.70" })

hl.window_rule({ name = "suppress-maximize-events", match = { class = ".*" }, suppress_event = "maximize" })

hl.window_rule({
  name = "fix-xwayland-drags",
  match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
  no_focus = true,
})
