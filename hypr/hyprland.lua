-- qings hyprland.lua
------------------
---- MONITORS ----
------------------
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "eDP-1",
    mode     = "highrr",
    position = "auto",
    scale    = "auto",
})
hl.monitor({
    output = "HDMI-A-1",
    mirror = "eDP-1",
    -- mode     = "preferred",
    -- position = "auto",
    -- scale    = "auto",
})

---------------------
---- MY PROGRAMS ----
---------------------
-- Set programs that you use
local terminal    = "kitty"
local fileManager = "nemo"
local menu        = "walker"
local browser     = "google-chrome-stable"
local imageViewr  = "swayimg"
local videoViewr  = "Celluloid"
local notifier    = "swaync"
local coder       = "code"
local archiver    = "xarchiver"
local clipboard   = "wl-clipboard"
local statusBar   = "waybar"
local wallpaper   = "hyprpaper"

-------------------
---- AUTOSTART ----
-------------------
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    hl.exec_cmd(statusBar)
    hl.exec_cmd(wallpaper)
    hl.exec_cmd(clipboard)
    hl.exec_cmd("walker --gapplication-service")
    -- hl.exec_cmd(notifier)
    hl.exec_cmd("singboxUi")
    -- hl.exec_cmd("sunshine")
    -- hl.exec_cmd("aria2c --enable-rpc -x 16 --split=16 -d ~/Downloads -D") -- aria2 rpc service
    hl.exec_cmd("elephant &")
    hl.exec_cmd("systemctl --user start hyprpolkitagent || hyprpolkitagent")
    hl.exec_cmd("fcitx5 -d --replace")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("EDITOR", "nvim")    -- 编辑器
hl.env("LANG", "zh_CN.UTF-8") -- 语言
hl.env("LC_ALL", "zh_CN.UTF-8")
hl.env("XMODIFIERS", "@im=fcitx")   -- 修复输入法
-- hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("GTK_THEME", "Adwaita:dark") -- 设置深色主题
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
hl.config({ -- 修复xWayland应用缩放模糊
    xwayland = {
        force_zero_scaling = true
    }
})
hl.env("GDK_SCALE", "2")
hl.env("QT_SCALE_FACTOR", "1.6")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- 代理
local proxy_host="192.168.6.5:20122"
-- local proxy_host="127.0.0.1:20122"
hl.env("http_proxy", "http://"..proxy_host)
hl.env("https_proxy", "http://"..proxy_host)
hl.env("all_proxy", "socks5://"..proxy_host)
hl.env("no_proxy", "localhost,127.0.0.1,::1")

-----------------------
----- PERMISSIONS -----
-----------------------
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons3

-- hl.config({
--   ecosystem = {
--     enforce_permissions = true,
--   },
-- })

-- hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
-- hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
-- hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")


-----------------------
---- LOOK AND FEEL ----
-----------------------
-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in          = 5,
        gaps_out         = 10,

        border_size      = 2,

        col              = {
            active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing    = false,

        layout           = "dwindle",
    },

    decoration = {
        rounding         = 10,
        rounding_power   = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 1,
        inactive_opacity = 0.90,

        shadow           = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },
        blur             = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})

-- Default curves and animations, see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- Default springs
hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, spring = "easy", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
    dwindle = {
        preserve_split = true, -- You probably want this
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
    master = {
        new_status = "master",
    },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
    scrolling = {
        fullscreen_on_one_column = true,
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = -1,    -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        kb_layout    = "us",
        kb_variant   = "",
        kb_model     = "",
        kb_options   = "",
        kb_rules     = "",

        follow_mouse = 2,

        sensitivity  = -0.15, -- -1.0 - 1.0, 0 means no modification.

        touchpad     = {
            natural_scroll = true,
            scroll_factor = 0.5
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})

-- Example per-device config
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Devices/ for more
hl.device({
    name        = "epic-mouse-v1",
    sensitivity = -0.5,
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
hl.bind(mainMod .. " + M",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- qings
-- Hyprshot
hl.bind(mainMod .. "+SHIFT" .. "+A", hl.dsp.exec_cmd("hyprshot -m region -c"))          -- 区域截图
hl.bind(mainMod .. "+SHIFT" .. "+W", hl.dsp.exec_cmd("hyprshot -m window -c"))          -- 窗口截图
hl.bind(mainMod .. "+SHIFT" .. "+D", hl.dsp.exec_cmd("hyprshot -m output -c"))          -- 显示器截图
-- OBS
hl.bind(mainMod .. "+F10", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" })) -- 暂停/恢复录制
hl.bind(mainMod .. "+F11", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" })) -- 开始录制
hl.bind(mainMod .. "+F12", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" })) -- 停止录制
-- Mission center
hl.bind(mainMod .. "+ESCAPE", hl.dsp.exec_cmd("missioncenter"))
-- Code-OSS
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd(coder))
-- 绑定 Super + V 唤起剪贴板历史
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("walker -m clipboard"))
--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

-- Example window rules that are useful

local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name           = "suppress-maximize-events",
    match          = { class = ".*" },

    suppress_event = "maximize",
})
-- suppressMaximizeRule:set_enabled(false)

hl.window_rule({
    -- Fix some dragging issues with XWayland
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

-- Layer rules also return a handle.
-- local overlayLayerRule = hl.layer_rule({
--     name  = "no-anim-overlay",
--     match = { namespace = "^my-overlay$" },
--     no_anim = true,
-- })
-- overlayLayerRule:set_enabled(false)

hl.window_rule({ -- Hyprland-run windowrule
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})
hl.window_rule({ -- Network Manager
    name   = "network_manager-float",
    match  = {
        class = "nm-connection-editor"
    },
    float  = true,
    center = true,
    size   = "monitor_w*0.3 monitor_h*0.6"
})
hl.window_rule({ -- Blueman Manager
    name   = "blueman_manager-float",
    match  = {
        class = "blueman-manager"
    },
    float  = true,
    center = true,
    size   = "monitor_w*0.3 monitor_h*0.6"
})
hl.window_rule({ -- Fcitx5 Configurator
    name   = "fcitx5_configurator-float",
    match  = {
        class = "org.fcitx.fcitx5-config-qt"
    },
    float  = true,
    center = true,
    size   = "monitor_w*0.3 monitor_h*0.6"
})
hl.window_rule({ -- Pavucontrol
    name   = "pavucontrol-float",
    match  = {
        class = "org.pulseaudio.pavucontrol"
    },
    float  = true,
    center = true,
    size   = "monitor_w*0.3 monitor_h*0.6"
})
hl.window_rule({ -- Terminal
    name = "terminal-wait-load",
    match = {
        class = "^.*(?i)" .. terminal .. ".*$"
    },
    no_close_for = 200
})
hl.window_rule({ -- Mission Center
    name   = "mission_center-float",
    match  = {
        class = "io.missioncenter.MissionCenter"
    },
    float  = true,
    center = true,
    size   = "monitor_w*0.75 monitor_h*0.75"
})
hl.window_rule({ -- ImageViewr
    name   = "imageViewr-float",
    match  = {
        class = "^.*(?i)" .. imageViewr .. ".*$",
    },
    float  = true,
    center = true,
})
hl.window_rule({ -- VideoViewr
    name   = "videoViewr-float",
    match  = {
        class = "^.*(?i)" .. videoViewr .. ".*$",
    },
    float  = true,
    center = true,
})
hl.window_rule({ -- FileManager
    name   = "fileManager-float",
    match  = {
        class = "^.*(?i)" .. fileManager .. ".*$",
    },
    float  = true,
    center = true,
})
hl.window_rule({ -- Archiver
    name   = "archiver-float",
    match  = {
        class = "^.*(?i)" .. archiver .. ".*$",
    },
    float  = true,
    center = true,
})
hl.window_rule({ -- Steam
    name = "steam-subwindows-float",
    match = {
        class = "steam",
        title = "negative:^Steam$"
    },
    float = true,
    center = true
})
hl.window_rule({ -- Telegram
    name   = "telegram-subwindows-float",
    match  = {
        class = "org.telegram.desktop",
        title = "negative:^Telegram$"
    },
    float  = true,
    center = true,
})
hl.window_rule({ -- Wechat
    name   = "wechat-subwindows-float",
    match  = {
        class = "wechat",
        title = "negative:^微信$"
    },
    float  = true,
    center = true,
})
hl.window_rule({ -- QQ
    name   = "qq-subwindows-float",
    match  = {
        class = "QQ",
        title = "negative:^QQ$"
    },
    float  = true,
    center = true,
})
