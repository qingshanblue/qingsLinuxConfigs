-- 窗口与工作区规则 (WINDOW & WORKSPACE RULES)
-- 参考: https://wiki.hypr.land/Configuring/Basics/Window-Rules/
--       https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

local apps     = require("apps.defs")
local dimRules = require("features.power").dimRules

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. 系统底层与合成器修复
-- ═══════════════════════════════════════════════════════════════════════════

-- 忽略所有应用的 maximize 请求
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- 修复 XWayland 的拖拽假死/黑框问题
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

-- 终端防手抖: 打开后 200ms 内不可快速关闭
hl.window_rule({
    name         = "terminal-wait-load",
    match        = { class = "^.*(?i)" .. apps.terminal .. ".*$" },
    no_close_for = 200,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. 特殊工作区外观样式 (边框色与动态透明度)
-- ═══════════════════════════════════════════════════════════════════════════

-- 特殊工作区辨识边框色 (Catppuccin 主题色: magic/Z=红, maho/X=绿, mofa/C=蓝)
hl.window_rule({
    name         = "special-magic-border",
    match        = { workspace = "special:magic" },
    border_color = "rgba(f38ba8dd)",
})
hl.window_rule({
    name         = "special-maho-border",
    match        = { workspace = "special:maho" },
    border_color = "rgba(a6e3a1dd)",
})
hl.window_rule({
    name         = "special-mofa-border",
    match        = { workspace = "special:mofa" },
    border_color = "rgba(89b4fadd)",
})

-- 特殊工作区微透明 (注册至 dimRules: 性能模式下 0.96，省电模式下自动禁用变为 1.0 全不透明)
table.insert(dimRules, hl.window_rule({
    name    = "special-magic-dim",
    match   = { workspace = "special:magic" },
    opacity = 0.96,
}))
table.insert(dimRules, hl.window_rule({
    name    = "special-maho-dim",
    match   = { workspace = "special:maho" },
    opacity = 0.96,
}))
table.insert(dimRules, hl.window_rule({
    name    = "special-mofa-dim",
    match   = { workspace = "special:mofa" },
    opacity = 0.96,
}))

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. 系统工具与配置面板 (默认居中悬浮)
-- ═══════════════════════════════════════════════════════════════════════════

-- Hyprland-run
hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move  = "20 monitor_h-120",
    float = true,
})

-- 网络管理 (NetworkManager)
hl.window_rule({
    name   = "network_manager-float",
    match  = { class = "nm-connection-editor" },
    float  = true,
    center = true,
    size   = "monitor_w*0.3 monitor_h*0.6",
})

-- 蓝牙管理 (Blueman)
hl.window_rule({
    name   = "blueman_manager-float",
    match  = { class = "blueman-manager" },
    float  = true,
    center = true,
    size   = "monitor_w*0.3 monitor_h*0.6",
})

-- Fcitx5 配置器
hl.window_rule({
    name   = "fcitx5_configurator-float",
    match  = { class = "org.fcitx.fcitx5-config-qt" },
    float  = true,
    center = true,
    size   = "monitor_w*0.3 monitor_h*0.6",
})

-- 音量控制器 (Pavucontrol)
hl.window_rule({
    name   = "pavucontrol-float",
    match  = { class = "org.pulseaudio.pavucontrol" },
    float  = true,
    center = true,
    size   = "monitor_w*0.3 monitor_h*0.6",
})

-- Better Control (系统控制中心)
hl.window_rule({
    name      = "better-control-float",
    match     = { initial_title = "Better Control" },
    float     = true,
    center    = true,
    size      = "monitor_w*0.3 monitor_h*0.6",
    animation = "popin 85%",
})

-- 任务管理器 (Mission Center)
hl.window_rule({
    name   = "mission_center-float",
    match  = { class = "io.missioncenter.MissionCenter" },
    float  = true,
    center = true,
    size   = "monitor_w*0.75 monitor_h*0.75",
})

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. 媒体、查看器与实用工具
-- ═══════════════════════════════════════════════════════════════════════════

-- 截图钉窗 (Ctrl+D 区域截图，居中悬浮并钉住)
hl.window_rule({
    name     = "swayimg-pinshot",
    match    = { class = "pinshot" },
    float    = true,
    pin      = true,
    center   = true,
    max_size = "monitor_w*0.8 monitor_h*0.8",
})

-- 图片查看器
hl.window_rule({
    name   = "imageViewr-float",
    match  = { class = "^.*(?i)" .. apps.imageViewr .. ".*$" },
    float  = true,
    center = true,
})

-- 视频播放器
hl.window_rule({
    name   = "videoViewr-float",
    match  = { class = "^.*(?i)" .. apps.videoViewr .. ".*$" },
    float  = true,
    center = true,
})

-- 文件管理器
hl.window_rule({
    name   = "fileManager-float",
    match  = { class = "^.*(?i)" .. apps.fileManager .. ".*$" },
    float  = true,
    center = true,
})

-- 压缩包管理器
hl.window_rule({
    name   = "archiver-float",
    match  = { initial_class = "^org.kde.ark$" },
    float  = true,
    center = true,
})

-- Motrix Next (下载管理器)
hl.window_rule({
    name   = "rayburst-float",
    match  = { initial_class = "rayburst" },
    float  = true,
    center = true,
    size   = "monitor_w*0.6 monitor_h*0.7",
})

-- ═══════════════════════════════════════════════════════════════════════════
-- 5. 聊天与游戏子窗口 (仅弹窗浮动，主界面保持平铺)
-- ═══════════════════════════════════════════════════════════════════════════

-- Steam 子窗口
hl.window_rule({
    name   = "steam-subwindows-float",
    match  = { class = "steam", title = "negative:^Steam$" },
    float  = true,
    center = true,
})

-- Telegram 弹窗
hl.window_rule({
    name   = "telegram-subwindows-float",
    match  = { class = "org.telegram.desktop", title = "negative:^Telegram$" },
    float  = true,
    center = true,
})

-- 微信子窗口
hl.window_rule({
    name   = "wechat-subwindows-float",
    match  = { class = "wechat", title = "negative:^微信$" },
    float  = true,
    center = true,
})

-- QQ 子窗口
hl.window_rule({
    name   = "qq-subwindows-float",
    match  = { class = "QQ", title = "negative:^QQ$" },
    float  = true,
    center = true,
})
