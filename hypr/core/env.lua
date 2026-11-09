-- 环境变量 (ENVIRONMENT VARIABLES)
-- 参考: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- 默认编辑器
hl.env("EDITOR", "nvim")

-- 语言与区域设置
hl.env("LANG", "zh_TW.UTF-8")
hl.env("LC_ALL", "zh_TW.UTF-8")

-- 输入法 (fcitx5)
hl.env("XMODIFIERS", "@im=fcitx")
-- hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")

-- 外观主题
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")

-- 光标尺寸
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- 代理设置 (默认本机 sing-box 入口)
-- local proxy_host = "192.168.6.5:20122"  -- 局域网备选
local proxy_host = "127.0.0.1:20122"
hl.env("http_proxy", "http://" .. proxy_host)
hl.env("https_proxy", "http://" .. proxy_host)
hl.env("all_proxy", "socks5://" .. proxy_host)
hl.env("no_proxy", "localhost,127.0.0.1,::1")

-- 修复 xWayland 应用缩放模糊
-- 合成器对显示器做 scale（eDP-1 = 1.6）→ Wayland 原生程序（GTK/Qt/Electron/Chromium）
-- 自动正确。这里绝不能再设 GDK_SCALE / QT_SCALE_FACTOR：Qt/GTK 在 Wayland 下会把
-- 它们乘在合成器 scale 之上（1.6 x 1.6 = 2.56），FreeCAD / OpenSCAD 异常放大就是这么来的。
-- force_zero_scaling 让 XWayland 保持 1:1 物理像素（2560x1440 @96dpi：清晰，
-- 但只有应有大小的 1/1.6）。补救办法：各 X11 程序自己按 1.6 渲染，且只能按程序设，
-- 全局设会伤到 Wayland 原生程序。落地都在 /etc/nixos/configuration.nix：
--   hmcl → HMCL_UI_SCALE=1.6（JavaFX 支持分数）
--   stm32cubemx → sun.java2d.uiScale=2（Java2D 只支持整数，2 比 1.6 大 25%）
--   steam → pkgs.steam.override { extraEnv.GDK_SCALE = "2"; }（GTK 只支持整数；
--           走 Chromium/CEF 的 GTK 集成，能放大内嵌 Web UI）
-- 注意 wechat 不在名单里：4.1 实测是 Wayland 原生，合成器缩放对它已经生效。
-- hl.env("GDK_SCALE", "2")          -- 全局设 = Wayland GTK 也中招；X11 下还只有整数
-- hl.env("QT_SCALE_FACTOR", "1.6")   -- 全局设 = Wayland Qt 双重重缩放
hl.config({ xwayland = { force_zero_scaling = true } })
