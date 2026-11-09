-- 启动 (AUTOSTART) 与环境变量 (ENVIRONMENT VARS)

local wallpaper = require("conf.programs").wallpaper

-- 参考:https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    -- 状态栏
    -- hl.exec_cmd(statusBar)
    -- 壁纸
    hl.exec_cmd(wallpaper)
    -- 应用启动器常驻服务
    hl.exec_cmd("walker --gapplication-service")
    -- 通知守护(当前未启用)
    -- hl.exec_cmd(notifier)
    -- sing-box 面板,改由 systemd 服务 webui-for-singbox 托管
    -- hl.exec_cmd("singboxUi")
    -- 串流主机
    hl.exec_cmd("sunshine")
    -- aria2 RPC 服务(未启用)
    -- hl.exec_cmd("aria2c --enable-rpc -x 16 --split=16 -d ~/Downloads -D")
    -- elephant 改由 NixOS 官方模块 services.elephant 托管(systemd 用户服务);装完新软件后 systemctl --user restart elephant 刷新应用列表
    -- 已切换 UWSM 会话(configuration.nix defaultSession):会话环境由 UWSM 导入、graphical-session.target 正常激活,官方挂载点原生工作
    -- 旧补丁(SDDM 直启时代的临时方案)保留备用:
    -- hl.exec_cmd("systemctl --user import-environment && systemctl --user restart elephant")
    -- polkit 认证代理
    hl.exec_cmd("systemctl --user start hyprpolkitagent || hyprpolkitagent")
    -- 空闲息屏/锁屏守护:配置在 ~/.config/hypr/hypridle.conf(当前全注释,刻意未启用;需要时取消下面一行的注释)
    -- hl.exec_cmd("hypridle")
    -- 输入法
    hl.exec_cmd("fcitx5 -d --replace")
    -- 开机自启 pi:静默开在特殊工作区(scratchpad),平时不可见
    -- hl.exec_cmd("[workspace special:magic silent] " .. terminal .. " --title pi pi")
    -- 自动登录后自锁,提升安全性
    hl.exec_cmd("hyprlock")
end)

-- 参考:https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

-- 编辑器
hl.env("EDITOR", "nvim")
-- 语言与区域
hl.env("LANG", "zh_TW.UTF-8")
hl.env("LC_ALL", "zh_TW.UTF-8")
-- 输入法(fcitx5)
hl.env("XMODIFIERS", "@im=fcitx")
-- hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")
-- 深色主题
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
-- 修复 xWayland 应用缩放模糊
hl.config({ xwayland = { force_zero_scaling = true } })
-- 缩放与光标
-- 合成器对显示器做 scale（eDP-1 = 1.6）→ Wayland 原生程序（GTK/Qt/Electron/Chromium）
-- 自动正确。这里绝不能再设 GDK_SCALE / QT_SCALE_FACTOR：Qt/GTK 在 Wayland 下会把
-- 它们乘在合成器 scale 之上（1.6 x 1.6 = 2.56），FreeCAD / OpenSCAD 异常放大就是这么来的。
-- 上面的 force_zero_scaling 让 XWayland 保持 1:1 物理像素（2560x1440 @96dpi：清晰，
-- 但只有应有大小的 1/1.6）。补救办法：各 X11 程序自己按 1.6 渲染，且只能按程序设，
-- 全局设会伤到 Wayland 原生程序。落地都在 /etc/nixos/configuration.nix：
--   hmcl → HMCL_UI_SCALE=1.6（JavaFX 支持分数）
--   stm32cubemx → sun.java2d.uiScale=2（Java2D 只支持整数，2 比 1.6 大 25%）
--   steam → pkgs.steam.override { extraEnv.GDK_SCALE = "2"; }（GTK 只支持整数；
--           走 Chromium/CEF 的 GTK 集成，能放大内嵌 Web UI）
-- 注意 wechat 不在名单里：4.1 实测是 Wayland 原生，合成器缩放对它已经生效。
-- hl.env("GDK_SCALE", "2")          -- 全局设 = Wayland GTK 也中招；X11 下还只有整数
-- hl.env("QT_SCALE_FACTOR", "1.6")   -- 全局设 = Wayland Qt 双重重缩放
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- 代理
-- local proxy_host = "192.168.6.5:20122"  -- 局域网备选
local proxy_host = "127.0.0.1:20122"
hl.env("http_proxy", "http://" .. proxy_host)
hl.env("https_proxy", "http://" .. proxy_host)
hl.env("all_proxy", "socks5://" .. proxy_host)
hl.env("no_proxy", "localhost,127.0.0.1,::1")
