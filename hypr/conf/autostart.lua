-- 开机自启 (AUTOSTART)

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
