-- 开机自启服务与程序 (AUTOSTART)
-- 参考: https://wiki.hypr.land/Configuring/Basics/Autostart/

local wallpaper = require("apps.defs").wallpaper

hl.on("hyprland.start", function()
    -- 状态栏 (当前改由 systemd 用户服务 dms.service 托管)
    -- hl.exec_cmd(statusBar)

    -- 壁纸守护
    hl.exec_cmd(wallpaper)

    -- 应用启动器常驻服务 (加速 Walker 呼出)
    hl.exec_cmd("walker --gapplication-service")

    -- 通知守护 (当前未启用)
    -- hl.exec_cmd(notifier)

    -- sing-box 面板 (改由 systemd 服务 webui-for-singbox 托管)
    -- hl.exec_cmd("singboxUi")

    -- Sunshine 串流主机服务
    hl.exec_cmd("sunshine")

    -- aria2 RPC 服务 (当前未启用)
    -- hl.exec_cmd("aria2c --enable-rpc -x 16 --split=16 -d ~/Downloads -D")

    -- elephant 应用列表索引 (由 NixOS services.elephant systemd 用户服务托管)
    -- UWSM 会话环境下由 graphical-session.target 正常激活

    -- Polkit 认证代理
    hl.exec_cmd("systemctl --user start hyprpolkitagent || hyprpolkitagent")

    -- 空闲息屏/锁屏守护 (配置在 ~/.config/hypr/hypridle.conf)
    -- hl.exec_cmd("hypridle")

    -- Fcitx5 输入法守护
    hl.exec_cmd("fcitx5 -d --replace")

    -- 开机自启 pi: 静默开在特殊工作区 (scratchpad), 平时不可见
    -- hl.exec_cmd("[workspace special:magic silent] " .. terminal .. " --title pi pi")

    -- 自动登录后自锁, 提升随身安全性
    hl.exec_cmd("hyprlock")
end)
