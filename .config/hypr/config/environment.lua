hl.env("GBM_BACKEND", "nvidia-drm")           -- force GBM as a backend
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia") -- force GBM as a backend
hl.env("LIBVA_DRIVER_NAME", "nvidia")         -- Hardware acceleration on NVIDIA GPUs
-- hl.env("__GL_GSYNC_ALLOWED", "1") -- Controls if G-Sync capable monitors should use Variable Refresh Rate (VRR)
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
