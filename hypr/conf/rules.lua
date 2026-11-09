-- 窗口 / 工作区规则 (WINDOWS AND WORKSPACES)

local terminal = require("conf.programs").terminal
local fileManager = require("conf.programs").fileManager
local imageViewr = require("conf.programs").imageViewr
local videoViewr = require("conf.programs").videoViewr
local dimRules = require("conf.power").dimRules

-- 参考:https://wiki.hypr.land/Configuring/Basics/Window-Rules/
--      https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- 忽略所有应用的 maximize 请求
local suppressMaximizeRule = hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})
-- 修复 XWayland 的拖拽问题
hl.window_rule({
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})
-- 特殊工作区边框色(与按键助记对应:magic(Z)=红 / maho(X)=绿 / mofa(C)=蓝,catppuccin 色板)
hl.window_rule({
    name         = "special-magic",
    match        = { workspace = "special:magic" },
    border_color = "rgba(f38ba8dd)",
})
hl.window_rule({
    name         = "special-maho",
    match        = { workspace = "special:maho" },
    border_color = "rgba(a6e3a1dd)",
})
hl.window_rule({
    name         = "special-mofa",
    match        = { workspace = "special:mofa" },
    border_color = "rgba(89b4fadd)",
})
-- 特殊工作区半透明(仅性能模式;省电模式由 dimRules 关掉 → 不透明)
table.insert(dimRules, hl.window_rule({
    name    = "special-magic-dim",
    match   = { workspace = "special:magic" },
    opacity = 0.96,
}))
table.insert(dimRules, hl.window_rule({
    name    = "special-magic-dim",
    match   = { workspace = "special:maho" },
    opacity = 0.96,
}))
table.insert(dimRules, hl.window_rule({
    name    = "special-magic-dim",
    match   = { workspace = "special:mofa" },
    opacity = 0.96,
}))
-- Hyprland-run 窗口
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})
-- 网络管理器(NetworkManager)
hl.window_rule({
    name   = "network_manager-float",
    match  = { class = "nm-connection-editor" },
    float  = true,
    center = true,
    size   = "monitor_w*0.3 monitor_h*0.6"
})
-- 蓝牙管理器(Blueman)
hl.window_rule({
    name   = "blueman_manager-float",
    match  = { class = "blueman-manager" },
    float  = true,
    center = true,
    size   = "monitor_w*0.3 monitor_h*0.6"
})
-- fcitx5 配置器
hl.window_rule({
    name   = "fcitx5_configurator-float",
    match  = { class = "org.fcitx.fcitx5-config-qt" },
    float  = true,
    center = true,
    size   = "monitor_w*0.3 monitor_h*0.6"
})
-- 音量控制(Pavucontrol)
hl.window_rule({
    name   = "pavucontrol-float",
    match  = { class = "org.pulseaudio.pavucontrol" },
    float  = true,
    center = true,
    size   = "monitor_w*0.3 monitor_h*0.6"
})
-- better-control(系统控制面板;用可用的 popin 动画,去掉不兼容的 dimaround)
hl.window_rule({
    name      = "better-control-float",
    match     = { initial_title = "Better Control" },
    float     = true,
    center    = true,
    size      = "monitor_w*0.3 monitor_h*0.6",
    animation = "popin 85%"
})
-- 终端:打开后 200ms 内不可关闭
hl.window_rule({
    name         = "terminal-wait-load",
    match        = { class = "^.*(?i)" .. terminal .. ".*$" },
    no_close_for = 200,
})
-- 任务管理器(Mission Center)
hl.window_rule({
    name   = "mission_center-float",
    match  = { class = "io.missioncenter.MissionCenter" },
    float  = true,
    center = true,
    size   = "monitor_w*0.75 monitor_h*0.75"
})
-- 截图钉窗:Ctrl+D 区域截图,居中悬浮 + 钉住;窗口自适应图片,最大不超过屏幕八成
hl.window_rule({
    name     = "swayimg-pinshot",
    match    = { class = "pinshot" },
    float    = true,
    pin      = true,
    center   = true,
    max_size = "monitor_w*0.8 monitor_h*0.8",
})
-- 图片查看器(swayimg)
hl.window_rule({
    name   = "imageViewr-float",
    match  = { class = "^.*(?i)" .. imageViewr .. ".*$" },
    float  = true,
    center = true,
})
-- 视频播放器(Celluloid)
hl.window_rule({
    name   = "videoViewr-float",
    match  = { class = "^.*(?i)" .. videoViewr .. ".*$" },
    float  = true,
    center = true,
})
-- 文件管理器(nemo)
hl.window_rule({
    name   = "fileManager-float",
    match  = { class = "^.*(?i)" .. fileManager .. ".*$" },
    float  = true,
    center = true,
})
-- 压缩包管理器(ark)
hl.window_rule({
    name   = "archiver-float",
    match  = { initial_class = "^org.kde.ark$"},
    float  = true,
    center = true,
    
})
-- Steam 子窗口(弹窗)
hl.window_rule({
    name   = "steam-subwindows-float",
    match  = { class = "steam", title = "negative:^Steam$" },
    float  = true,
    center = true
})
-- Telegram 子窗口(弹窗)
hl.window_rule({
    name   = "telegram-subwindows-float",
    match  = { class = "org.telegram.desktop", title = "negative:^Telegram$" },
    float  = true,
    center = true,
})
-- 微信子窗口(弹窗)
hl.window_rule({
    name   = "wechat-subwindows-float",
    match  = { class = "wechat", title = "negative:^微信$" },
    float  = true,
    center = true,
})
-- QQ 子窗口(弹窗)
hl.window_rule({
    name   = "qq-subwindows-float",
    match  = { class = "QQ", title = "negative:^QQ$" },
    float  = true,
    center = true,
})
-- Motrix Next(下载器)
hl.window_rule({
    name   = "rayburst-float",
    match  = { initial_class = "rayburst" },
    float  = true,
    center = true,
    size   = "monitor_w*0.6 monitor_h*0.7"
})
