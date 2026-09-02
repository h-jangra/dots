hl.on("hyprland.start", function()
  hl.exec_cmd("dbus-update-activation-environment --systemd --all")
  hl.exec_cmd("noctalia")
  hl.exec_cmd("xhost +SI:localuser:root")
end)

hl.on("workspace.special_active", function()
  hl.exec_cmd("noctalia msg bar-toggle")
end)
