-- qings hyprland.lua
------------------
---- MONITORS ----
------------------
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "eDP-1",
    mode     = "highrr",
    position = "0x0",
    scale    = "auto",
})
-- hl.monitor({
--     output   = "eDP-2",
--     mode     = "highrr",
--     position = "auto",
--     scale    = "auto",
-- })
hl.monitor({
    output    = "DP-1",
    mode      = "highrr",       -- 2560x1600@160Hz
    transform = 1,              -- 竖屏摆放;若画面上下颠倒,改成 3
    position  = "-1600x-0",  -- 主屏左侧、底边对齐;竖屏后高 2560,上边界远高于主屏
    scale     = 1.6,
})

hl.monitor({
    output = "HDMI-A-1",
    mirror = "eDP-1",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
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
local archiver    = "ark"
local statusBar   = "waybar"
local wallpaper   = "hyprpaper"

-------------------
---- AUTOSTART ----
-------------------
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    hl.exec_cmd(statusBar)
    hl.exec_cmd(wallpaper)
    hl.exec_cmd("walker --gapplication-service")
    -- hl.exec_cmd(notifier)
    -- hl.exec_cmd("singboxUi") -- 改由 systemd 服务 webui-for-singbox 托管
    hl.exec_cmd("sunshine")
    -- hl.exec_cmd("aria2c --enable-rpc -x 16 --split=16 -d ~/Downloads -D") -- aria2 rpc service
    hl.exec_cmd("elephant &")
    hl.exec_cmd("systemctl --user start hyprpolkitagent || hyprpolkitagent")
    -- hl.exec_cmd("hypridle")  -- 空闲息屏/锁屏守护:配置在 ~/.config/hypr/hypridle.conf(当前全注释,刻意未启用;需要时取消注释并放开本行)
    hl.exec_cmd("fcitx5 -d --replace")
    -- 开机自启 pi:静默开在特殊工作区(scratchpad),平时不可见
    -- 按 Super+S 呼出/隐藏(见下方 keybindings 的 toggle_special("magic"))
    hl.exec_cmd("[workspace special:magic silent] " .. terminal .. " --title pi pi")
    hl.exec_cmd("hyprlock")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("EDITOR", "nvim")    -- 编辑器
hl.env("LANG", "zh_TW.UTF-8") -- 语言
hl.env("LC_ALL", "zh_TW.UTF-8")
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
-- local proxy_host="192.168.6.5:20122"
local proxy_host="127.0.0.1:20122"
hl.env("http_proxy", "http://"..proxy_host)
hl.env("https_proxy", "http://"..proxy_host)
hl.env("all_proxy", "socks5://"..proxy_host)
hl.env("no_proxy", "localhost,127.0.0.1,::1")

-----------------------
----- PERMISSIONS -----
-----------------------
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

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
hl.config({
    general = {
        gaps_in     = 4,
        gaps_out    = 12,   -- 外围留多点呼吸感,窗口像"悬浮卡片"

        border_size = 2,    -- 想让渐变更显眼可以试 3

        col = {
            -- 三选一,混搭也行:
            -- A. 冰青(你原来的风格,降饱和更耐看)
            active_border   = { colors = { "rgba(89dcebee)", "rgba(94e2d5ee)" }, angle = 45 },
            -- B. Catppuccin 蓝紫(和下面 inactive 灰最搭)
            -- active_border = { colors = { "rgba(89b4faee)", "rgba(cba6f7ee)" }, angle = 45 },
            -- C. 樱花粉紫
            -- active_border = { colors = { "rgba(f5c2e7ee)", "rgba(cba6f7ee)" }, angle = 45 },

            inactive_border = "rgba(45475aaa)",
        },

        resize_on_border = false,
        allow_tearing    = false,
        layout           = "scrolling",   -- 无限平铺;想回老手感改回 "dwindle"
    },

    -- 移除了不兼容的 render 块

    decoration = {
        rounding       = 12,
        rounding_power = 2,

        active_opacity   = 0.95,
        inactive_opacity = 0.80,   -- 拉大聚焦对比

        shadow = {
            enabled      = true,
            range        = 20,          -- 大而柔的阴影比小硬阴影更有悬浮感
            render_power = 4,
            color        = 0xcc1a1a26,  -- 带一点蓝调的黑,更柔和
        },
        blur = {
            enabled    = true,
            size       = 8,       -- 3→8,模糊才看得出来
            passes     = 2,       -- 2 遍 + 大 size = 真正的磨砂玻璃
            vibrancy   = 0.1696,
            contrast   = 0.8916,  -- 这三个是经典"奶玻璃"配方
            brightness = 0.8172,
            noise      = 0.0117,
        },
    },

    animations = { enabled = true },
})

-- 自定义曲线
hl.curve("snappy", { type = "spring", mass = 1, stiffness = 230, dampening = 26 })
hl.curve("bouncy", { type = "spring", mass = 1, stiffness = 300, dampening = 22 })
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1 } } }) -- 标准缓出曲线

-- 窗口开合更有生命感(想要更弹就换成 bouncy)
hl.animation({ leaf = "windows",    enabled = true, speed = 4,   spring = "snappy" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 3.4, spring = "snappy", style = "popin 85%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.6, bezier = "linear", style = "popin 85%" })

-- 工作区切换:垂直滑动动画,配合三指上下滑切工作区的方向感
hl.animation({ leaf = "workspaces", enabled = true, speed = 5,   bezier = "easeOutQuint", style = "slidevert" })

-- 特殊工作区从底部滑入(不显式写的话会继承 workspaces 的动画,这里固定下来)
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.5, bezier = "easeOutQuint", style = "slidevert" })

-- ⭐ 渐变边框缓慢流动,配合上面 colors 渐变的 active_border
hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "linear", style = "loop" })

-- 其余 fadeIn/fadeOut/layers 等保持你现在的默认即可

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

        follow_mouse = 1,

        sensitivity  = -0.15, -- -1.0 - 1.0, 0 means no modification.

        touchpad     = {
            natural_scroll = true,
            scroll_factor = 0.33,
            clickfinger_behavior = true  -- 按指头数点击:1指=左键,2指=右键,3指=中键(替代右下角软按钮区)
        },
    },
})

-- 触控板手势:适配 scrolling 布局
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "scroll_move"   -- 左右滑:跟手滚动胶带(轴向一致,行程也长)
})
hl.gesture({
    fingers   = 3,
    direction = "vertical",
    action    = "workspace"     -- 上下滑:切换工作区
})
hl.gesture({
    fingers   = 4,
    direction = "up",
    action    = function()       -- 四指上滑:呼出 magic(已开着则原地不动)
        hl.dispatch(hl.dsp.focus({ workspace = "special:magic" }))
    end
})
hl.gesture({
    fingers   = 4,
    direction = "down",
    action    = function()       -- 四指下滑:仅当 magic 开着时收起
        if hl.get_active_special_workspace() ~= nil then
            hl.dispatch(hl.dsp.workspace.toggle_special("magic"))
        end
    end
})
-- Super+Shift+三指横滑:移动当前窗口(跟手,不用再按住鼠标键拖)
hl.gesture({ fingers = 3, direction = "horizontal", mods = "SUPER SHIFT", action = "move" })

-- Super+Shift+三指上下滑:窗口扔到上/下一个工作区(上滑=下一个,下滑=上一个;本工作区不跟随)
local ws_dy = 0
hl.gesture({
    fingers   = 3,
    direction = "vertical",
    mods      = "SUPER SHIFT",
    action    = {
        start  = function() ws_dy = 0 end,
        update = function(e) ws_dy = ws_dy + e.delta.y end,
        finish = function()
            if ws_dy < -40 then
                hl.dispatch(hl.dsp.window.move({ workspace = "e-1", follow = false })) -- 上滑:上一个
            elseif ws_dy > 40 then
                hl.dispatch(hl.dsp.window.move({ workspace = "e+1", follow = false })) -- 下滑:下一个
            end
        end
    }
})

-- Super+双指捏合:调整当前窗口大小(进入后按位移方向缩放,右下=放大/左上=缩小;不按 Super 的双指捏合留给应用缩放)
hl.gesture({ fingers = 2, direction = "pinch", mods = "SUPER", action = "resize" })
-- 三指捏合:跟手放大镜,锚定光标(再捏一次取消)
hl.gesture({ fingers = 3, direction = "pinch", action = "cursor_zoom", zoom_level = 1, mode = "live" })

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind("ALT + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind("ALT + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + W", hl.dsp.window.fullscreen({ action = "toggle" })) -- 全屏切换(scrolling 布局下可滚走,回来还是全屏)
hl.bind(mainMod .. " + E", hl.dsp.window.float({ action = "toggle" }))
hl.bind("ALT + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + R", hl.dsp.window.pin({ action = "toggle" })) -- 浮窗钉住:跨工作区置顶,对浮动窗口生效

-- scrolling 无限平铺
hl.bind(mainMod .. " + D", hl.dsp.layout("move +col"))           -- 视野右滚一列(WASD)
hl.bind(mainMod .. " + A", hl.dsp.layout("move -col"))           -- 视野左滚一列
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.layout("swapcol l"))        -- 当前列与左列交换
hl.bind(mainMod .. " + SHIFT + D", hl.dsp.layout("swapcol r"))        -- 当前列与右列交换
hl.bind(mainMod .. " + F",         hl.dsp.layout("colresize +conf"))       -- 列宽循环 0.33/0.5/0.667/1.0(高频)
hl.bind(mainMod .. " + G",         hl.dsp.layout("consume_or_expel next"))  -- 独列↔并入右列(窗口上下排↔并排)
hl.bind(mainMod .. " + T",         hl.dsp.layout("inhibit_scroll"))         -- 锁定/解锁本工作区的视野自动滚动(T=Tape)
hl.bind("ALT + B", hl.dsp.exec_cmd(browser))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Move active window with mainMod + SHIFT + arrow keys (Shift=移动窗口规则)
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "d" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- mainMod + TAB:在最近两个工作区之间快切(A/B)
hl.bind(mainMod .. " + TAB", function()
    local last = hl.get_last_workspace()
    if last ~= nil then hl.dispatch(hl.dsp.focus({ workspace = last })) end
end)

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Lock screen (Windows-like Super + L)
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Super+中键:呼出/收起 pi 终端(触控板上即 Super+三指轻点,clickfinger 三指点击=中键)
hl.bind(mainMod .. " + mouse:274", hl.dsp.workspace.toggle_special("magic"))

-- Super+侧键 前/后:胶带滚动(已按手感对调:前=左滚,后=右滚;裸侧键仍归应用)
hl.bind(mainMod .. " + mouse:276", hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + mouse:275", hl.dsp.layout("move +col"))

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
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- qings
-- Hyprshot
hl.bind("ALT + A", hl.dsp.exec_cmd("hyprshot -m region -z -o $HOME/Pictures/screenshot"))   -- 区域截图(框选时画面冻结)
hl.bind("ALT + W", hl.dsp.exec_cmd("hyprshot -m window -o $HOME/Pictures/screenshot"))   -- 窗口截图
-- Alt+D:区域截图并钉住(swayimg 悬浮右下,文件存 /tmp 重启自清;看完 Super+Q 关)
-- 注:hyprshot 1.3 的截图在后台子进程完成,主进程退出码恒为 1(它自带的 -- command 也只支持无参命令),
-- 故不依赖退出码:打时间戳→截图→轮询 pin.png 是否更新(30s 超时,Esc 取消则不弹窗)
hl.bind("ALT + D", hl.dsp.exec_cmd(
    "touch /tmp/.pin_stamp; hyprshot -m region -s -z -o /tmp -f pin.png; i=0; until [ /tmp/pin.png -nt /tmp/.pin_stamp ] || [ $i -ge 100 ]; do sleep 0.3; i=$((i+1)); done; j=0; while [ -n \"$(pgrep -x grim)\" ] && [ $j -lt 50 ]; do sleep 0.2; j=$((j+1)); done; if [ /tmp/pin.png -nt /tmp/.pin_stamp ]; then eval set -- $(hyprctl monitors | awk '$1==\"Monitor\"{mon=$2} $1~/^[0-9]+x[0-9]+@/{match($1,/x/);x1=RSTART;match($1,/@/);x2=RSTART;pw=substr($1,1,x1-1);ph=substr($1,x1+1,x2-x1-1)} /scale:/{sc=$2} /transform:/{tr=$2} $1==\"focused:\"&&$2==\"yes\"{if(tr%2==1){print int(ph/sc),int(pw/sc),int(sc*1000)}else{print int(pw/sc),int(ph/sc),int(sc*1000)}}'); MW=$1; MH=$2; SCM=$3; set -- $(od -An -j 16 -N 8 -t u1 /tmp/pin.png); W=$(($1*16777216+$2*65536+$3*256+$4)); H=$(($5*16777216+$6*65536+$7*256+$8)); W=$(($W*1000/SCM)); H=$(($H*1000/SCM)); S=1000; [ $(($MW*800)) -lt $(($W*1000)) ] && S=$(($MW*800/$W)); [ $(($MH*800)) -lt $(($H*1000)) ] && [ $(($MH*800/$H)) -lt $S ] && S=$(($MH*800/$H)); swayimg -a pinshot -S $(($W*S/1000)),$(($H*S/1000)) /tmp/pin.png; fi"
))
-- OBS
hl.bind("ALT + F10", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" })) -- 暂停/恢复录制
hl.bind("ALT + F11", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" })) -- 开始录制
hl.bind("ALT + F12", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" })) -- 停止录制
-- Mission center
hl.bind("ALT + ESCAPE", hl.dsp.exec_cmd("missioncenter"))
-- VS Code
hl.bind("ALT + C", hl.dsp.exec_cmd(coder))
-- Alt + V:剪贴板历史(walker)
hl.bind("ALT + V", hl.dsp.exec_cmd("walker -m clipboard"))
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
-- 特殊工作区做成磨砂玻璃:按 Super+S 时,当前桌面隔着一层雾,很有质感
hl.window_rule({
    name    = "special-magic-frost",
    match   = { workspace = "special:magic" },
    opacity = 0.9,
})

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
hl.window_rule({ -- better-conrtol
    name   = "better-control-float",
    match  = {
        initial_title = "Better Control"
    },
    float  = true,
    center = true,
    size   = "monitor_w*0.3 monitor_h*0.6",
    -- 恢复为可用的 popin 动画，移除不兼容的 dimaround
    animation = "popin 85%"
})
hl.window_rule({ -- Terminal
    name = "terminal-wait-load",
    match = {
        class = "^.*(?i)" .. terminal .. ".*$"
    },
    no_close_for = 200,
    opacity = 0.85
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
hl.window_rule({ -- 截图钉窗:Alt+D 区域截图,居中悬浮+钉住;窗口自适应图片,最大不超过屏幕八成
    name     = "swayimg-pinshot",
    match    = { class = "pinshot" },
    float    = true,
    pin      = true,
    center   = true,
    max_size = "monitor_w*0.8 monitor_h*0.8",
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
hl.window_rule({ -- Motrix Next
    name   = "motrix-next-float",
    match  = {
        initial_class = "motrix-next",
    },
    float  = true,
    center = true,
    size   = "monitor_w*0.3 monitor_h*0.7"
})