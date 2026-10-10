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
    mode      = "highrr",   -- 2560x1600@160Hz
    transform = 1,          -- 竖屏摆放;若画面上下颠倒,改成 3
    position  = "-1600x-0", -- 主屏左侧、底边对齐;竖屏后高 2560,上边界远高于主屏
    scale     = 1.6,
})
hl.monitor({
    output   = "HDMI-A-1",
    mirror   = "eDP-1",
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
    -- elephant 改由 NixOS 官方模块 services.elephant 托管(systemd 用户服务)，装完新软件后 systemctl --user restart elephant 即可刷新应用列表
    -- 已切换 UWSM 会话(configuration.nix defaultSession)：会话环境由 UWSM 导入、graphical-session.target 正常激活，官方挂载点原生工作
    -- 旧补丁(SDDM 直启时代的临时方案)保留备用：hl.exec_cmd("systemctl --user import-environment && systemctl --user restart elephant")
    hl.exec_cmd("systemctl --user start hyprpolkitagent || hyprpolkitagent")
    -- hl.exec_cmd("hypridle")  -- 空闲息屏/锁屏守护:配置在 ~/.config/hypr/hypridle.conf(当前全注释,刻意未启用;需要时取消注释并放开本行)
    hl.exec_cmd("fcitx5 -d --replace")
    -- hl.exec_cmd("[workspace special:magic silent] " .. terminal .. " --title pi pi") -- 开机自启 pi:静默开在特殊工作区(scratchpad),平时不可见
    hl.exec_cmd("hyprlock") -- 自动登录后自锁，提升安全性
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/
hl.env("EDITOR", "nvim")          -- 编辑器
hl.env("LANG", "zh_TW.UTF-8")     -- 语言
hl.env("LC_ALL", "zh_TW.UTF-8")
hl.env("XMODIFIERS", "@im=fcitx") -- 修复输入法
-- hl.env("GTK_IM_MODULE", "fcitx")
hl.env("QT_IM_MODULE", "fcitx")
hl.env("GTK_THEME", "Adwaita:dark")                     -- 设置深色主题
hl.env("QT_QPA_PLATFORMTHEME", "gtk3")
hl.config({ xwayland = { force_zero_scaling = true } }) -- 修复xWayland应用缩放模糊
hl.env("GDK_SCALE", "2")
hl.env("QT_SCALE_FACTOR", "1.6")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- 代理
-- local proxy_host="192.168.6.5:20122"
local proxy_host = "127.0.0.1:20122"
hl.env("http_proxy", "http://" .. proxy_host)
hl.env("https_proxy", "http://" .. proxy_host)
hl.env("all_proxy", "socks5://" .. proxy_host)
hl.env("no_proxy", "localhost,127.0.0.1,::1")

-----------------------
----- PERMISSIONS -----
-----------------------
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/



-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        gaps_in          = 4,
        gaps_out         = 12, -- 外围留多点呼吸感,窗口像"悬浮卡片"
        border_size      = 2,  -- 想让渐变更显眼可以试 3
        col              = {
            active_border   = {
                colors = { "rgba(cba6f7ee)", "rgba(f5c2e7ee)" }, -- 常规工作区=紫→粉渐变(备选:黄 f9e2af/琥珀 e5c890/暖白 f5e0dc)
                angle = 45
            },
            inactive_border = "rgba(8fb2c9aa)",
        },
        resize_on_border = false,
        allow_tearing    = false,
        layout           = "scrolling", -- 无限平铺;想回老手感改回 "dwindle"
    },
    decoration = {
        rounding         = 12,
        rounding_power   = 2,
        active_opacity   = 0.95,
        inactive_opacity = 0.80, -- 拉大聚焦对比
        shadow           = {
            enabled      = true,
            range        = 20,         -- 大而柔的阴影比小硬阴影更有悬浮感
            render_power = 4,
            color        = 0xcc1a1a26, -- 带一点蓝调的黑,更柔和
        },
        blur             = {
            enabled    = true,
            size       = 8,      -- 3→8,模糊才看得出来
            passes     = 2,      -- 2 遍+大 size = 真正的磨砂玻璃
            vibrancy   = 0.1696,
            contrast   = 0.8916, -- 这三个是经典"奶玻璃"配方
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
hl.animation({ leaf = "windows", enabled = true, speed = 4, spring = "snappy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.4, spring = "snappy", style = "popin 85%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.6, bezier = "linear", style = "popin 85%" })
-- 工作区切换:垂直滑动动画,配合三指上下滑切工作区的方向感
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "easeOutQuint", style = "slidevert" })
-- 特殊工作区从底部滑入(不显式写的话会继承 workspaces 的动画,这里固定下来)
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.5, bezier = "easeOutQuint", style = "slidevert" })
-- 渐变边框流动动画:loop 模式会持续重绘导致 VFR 完全失效(空闲时 GPU/CPU 也常驻工作),为续航关闭;想要流动效果改回 enabled = true
-- hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "linear", style = "loop" })
-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({ scrolling = { fullscreen_on_one_column = true, }, })

----------------
----  MISC  ----
----------------
hl.config({
    misc = {
        force_default_wallpaper = -1,   -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo   = true, -- If true disables the random hyprland logo / anime girl background. :(
        -- vfr(变帧率)默认即为 true,无需显式声明;此前 borderangle 常驻动画已关,VFR 现在能真正生效
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
        sensitivity  = 0, -- -1.0 - 1.0, 0 means no modification.
        touchpad     = {
            natural_scroll = true,
            scroll_factor = 0.33,
            clickfinger_behavior = true -- 按指头数点击:1指=左键,2指=右键,3指=中键(替代右下角软按钮区)
        },
    },
})
---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- ────────── 工作区导航(特殊区状态感知) ──────────
local specialOrder = { "magic", "mofa", "maho" }
local lastSpecial = "magic" -- 最近使用的特殊工作区(呼出类操作的目标)
-- 当前激活的特殊区名,没开则返回 nil
local function getActiveSpecialName()
    local raw = hl.get_active_special_workspace()
    -- 实测返回 userdata(HL.Workspace 对象),属性经 __index 暴露;多重兜底防 API 细节差异
    local cur = nil
    if type(raw) == "string" then
        cur = raw
    elseif type(raw) == "userdata" or type(raw) == "table" then
        local ok, name = pcall(function() return raw.name end)
        if ok and name ~= nil then
            cur = tostring(name)
        else
            cur = tostring(raw):match("special:([%w_%-]+)") -- 兜底:从 "HL.Workspace(-97:special:mofa)" 提取
        end
    end
    if cur ~= nil then cur = cur:gsub("^special:", "") end
    return cur
end
-- 当前特殊区的相邻项(首尾相接);cur 不在 specialOrder 内则返回 nil
local function adjacentSpecial(cur, dir)
    local idx = 0
    for i, name in ipairs(specialOrder) do
        if cur == name then idx = i break end
    end
    if idx == 0 then return nil end
    return specialOrder[((idx - 1 + dir) % #specialOrder) + 1]
end
-- dir=1 下一个,-1 上一个。特殊区开着时在 magic/mofa/maho 之间循环;未开时切换常规工作区
local function navWorkspace(dir)
    local cur = getActiveSpecialName()
    if cur == nil then
        if dir == 1 then
            hl.dispatch(hl.dsp.focus({ workspace = "e+1" })) -- 常规:下一个工作区
        else
            hl.dispatch(hl.dsp.focus({ workspace = "e-1" })) -- 常规:上一个工作区
        end
        return
    end
    local nxt = adjacentSpecial(cur, dir)
    if nxt == nil then return end
    lastSpecial = nxt
    hl.dispatch(hl.dsp.focus({ workspace = "special:" .. nxt }))
end
-- 扔窗口:特殊区开着时扔到相邻特殊区(人跟过去);未开时扔到相邻常规工作区
local function moveWindowNav(dir)
    local cur = getActiveSpecialName()
    if cur == nil then
        if dir == 1 then
            hl.dispatch(hl.dsp.window.move({ workspace = "e+1" })) -- 常规:下一个工作区
        else
            hl.dispatch(hl.dsp.window.move({ workspace = "e-1" })) -- 常规:上一个工作区
        end
        return
    end
    local nxt = adjacentSpecial(cur, dir)
    if nxt == nil then return end
    lastSpecial = nxt
    hl.dispatch(hl.dsp.window.move({ workspace = "special:" .. nxt }))
end
-- 点名 toggle(Z/X/C 用):开/切到该特殊区时记为最近使用;关闭时不动
local function toggleSpecialNamed(name)
    if getActiveSpecialName() ~= name then
        lastSpecial = name
    end
    hl.dispatch(hl.dsp.workspace.toggle_special(name))
end
-- 特殊区层开关:开着则直接收起当前,没开则呼出最近使用的(Super+V 与 Super+中键共用)
local function toggleSpecialLayer()
    local cur = getActiveSpecialName()
    if cur ~= nil then
        hl.dispatch(hl.dsp.workspace.toggle_special(cur))
    else
        hl.dispatch(hl.dsp.focus({ workspace = "special:" .. lastSpecial }))
    end
end
-- ────────── 适配 scrolling 布局 ──────────
-- Super+双指捏合:调整当前窗口大小(进入后按位移方向缩放,右下=放大/左上=缩小;不按 Super 的双指捏合留给应用缩放)
hl.gesture({
    fingers = 2,
    direction = "pinch",
    mods = mainMod,
    action = "resize"
})
-- 三指捏合:跟手放大镜,锚定光标(再捏一次取消)
hl.gesture({
    fingers = 3,
    direction = "pinch",
    action = "cursor_zoom",
    zoom_level = 1,
    mode = "live"
})
-- 左右滑:跟手滚动胶带(轴向一致,行程也长)
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "scroll_move"
})
-- Super+Shift+三指横滑:移动当前窗口(跟手,不用再按住鼠标键拖)
hl.gesture({
    fingers = 3,
    direction = "horizontal",
    mods = mainMod .. "+SHIFT",
    action = "move"
})
-- 上下滑:切换工作区(特殊工作区开着时在三个特殊区之间循环;上滑=下一个,下滑=上一个,与旧内置手势同向)
local gy3 = 0
hl.gesture({
    fingers   = 3,
    direction = "vertical",
    action    = {
        start  = function() gy3 = 0 end,
        update = function(e) gy3 = gy3 + e.delta.y end,
        finish = function()
            if gy3 < -40 then
                navWorkspace(1) -- 上滑:下一个
            elseif gy3 > 40 then
                navWorkspace(-1) -- 下滑:上一个
            end
        end
    }
})
-- Super+Shift+三指上下滑:窗口扔到上/下一个工作区(上滑=上一个,下滑=下一个;人跟过去,与 Shift+W/S 一致;特殊区开着时扔到相邻特殊区)
local ws_dy = 0
hl.gesture({
    fingers   = 3,
    direction = "vertical",
    mods      = mainMod .. "+SHIFT",
    action    = {
        start  = function() ws_dy = 0 end,
        update = function(e) ws_dy = ws_dy + e.delta.y end,
        finish = function()
            if ws_dy < -40 then
                moveWindowNav(-1) -- 上滑:上一个
            elseif ws_dy > 40 then
                moveWindowNav(1) -- 下滑:下一个
            end
        end
    }
})
-- 四指上滑:呼出最近使用的特殊工作区(已开着则原地不动)
hl.gesture({
    fingers   = 4,
    direction = "up",
    action    = function()
        if getActiveSpecialName() == nil then
            hl.dispatch(hl.dsp.focus({ workspace = "special:" .. lastSpecial }))
        end
    end
})
-- 四指下滑:有特殊区开着则直接收起当前的(不再固定跳到 magic)
hl.gesture({
    fingers   = 4,
    direction = "down",
    action    = function()
        local cur = getActiveSpecialName()
        if cur ~= nil then
            hl.dispatch(hl.dsp.workspace.toggle_special(cur))
        end
    end
})

-- ────────── 窗口状态(四态+鼠标拖拽) ──────────
-- 关闭窗口
hl.bind(mainMod .. "+Q", hl.dsp.window.close())
-- 全屏切换
hl.bind(mainMod .. "+E", hl.dsp.window.fullscreen({ action = "toggle" })) -- 全屏切换(scrolling 布局下可滚走,回来还是全屏)
-- 窗口浮动
hl.bind(mainMod .. "+F", hl.dsp.window.float({ action = "toggle" }))
-- 钉住浮动窗口
hl.bind(mainMod .. "+SHIFT +F", hl.dsp.window.pin({ action = "toggle" }))
-- 调整窗口位置
hl.bind(mainMod .. "+mouse:272", hl.dsp.window.drag(), { mouse = true })
-- 调整当前窗口大小
hl.bind(mainMod .. "+mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ────────── 布局调整(列与视野) ──────────
hl.bind(mainMod .. "+R", hl.dsp.layout("colresize +conf"))       -- 列宽循环 0.33/0.5/0.667/1.0(高频)
hl.bind(mainMod .. "+SHIFT +R", hl.dsp.layout("consume_or_expel next")) -- 独列↔并入右列(窗口上下排↔并排)
hl.bind(mainMod .. "+CTRL +SHIFT +R", hl.dsp.layout("inhibit_scroll"))      -- 锁定/解锁视野自动滚动

-- ────────── 省电模式切换(Super+Ctrl 层)与档位收敛 ──────────
-- 架构:ppd 档位 = 唯一事实源,特效作跟随者:
--   快捷键 powerMode() = 写档位 + 立即 applyVisuals;hl.timer 每 3s 轮询(sysfs 纯文件读):
--   ① EPP → 任何入口(better-control/CLI)改档位,特效 ≤3s 跟随;开机/重载首拍静默同步
--   ② AC 在线状态 → 插拔自动切档(拔电=power-saver,插电=balanced;边沿触发,首拍只建档)
-- 映射:epp=power → 省电视效;其余 → 性能视效。timer 只读不写档位,不会与 better-control 打架
-- 注意:恢复侧 0.95/0.80 需与上方 decoration 配置同步修改
local lastPerf = nil
local function applyVisuals(perf, notify)
    lastPerf = perf
    hl.config({
        animations = { enabled = perf },
        decoration = {
            active_opacity   = perf and 0.95 or 1,
            inactive_opacity = perf and 0.80 or 1,
            shadow = { enabled = perf },
            blur   = { enabled = perf },
        },
    })
    hl.monitor({ output = "eDP-1", mode = perf and "2560x1440@165" or "2560x1440@60", position = "0x0", scale = 1.6 })
    if notify ~= false then
        hl.notification.create({
            text = perf and "性能模式:特效全开 · 165Hz" or "省电模式:特效已关 · 60Hz",
            duration = 2500,
            color = perf and "rgb(a6e3a1)" or "rgb(f9e2af)",
        })
    end
end
local function powerMode(perf)
    hl.exec_cmd("powerprofilesctl set " .. (perf and "balanced" or "power-saver"))
    applyVisuals(perf)
end
hl.bind(mainMod .. "+CTRL +P", function() powerMode(false) end)       -- 进省电:动画/blur/阴影关,不透明,60Hz,CPU→power-saver
hl.bind(mainMod .. "+CTRL +SHIFT +P", function() powerMode(true) end) -- 回性能:特效全开,165Hz,CPU→balanced
-- 轮询①:档位→特效收敛(仅状态变化时动作,首拍静默同步)
local function syncVisuals()
    local f = io.open("/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference", "r")
    if not f then return end
    local epp = f:read("*l")
    f:close()
    local perf = (epp ~= "power")
    if perf ~= lastPerf then applyVisuals(perf, lastPerf ~= nil) end
end
-- 轮询②:AC 插拔自动切档(边沿触发;首拍只建档不动作,boot 档位交由 ppd/用户)
-- 注意:插拔边沿会覆盖手动选择(拔电必进省电/插电必回 balanced),标准笔记本语义
local lastAc = nil
local function acOnline()
    for _, p in ipairs({ "/sys/class/power_supply/AC0/online", "/sys/class/power_supply/AC/online" }) do
        local f = io.open(p, "r")
        if f then
            local v = f:read("*l")
            f:close()
            if v == "1" then return true elseif v == "0" then return false end
        end
    end
    return nil
end
local function pollPower()
    syncVisuals()
    local ac = acOnline()
    if ac ~= nil then
        if lastAc == nil then
            lastAc = ac
        elseif ac ~= lastAc then
            lastAc = ac
            powerMode(ac) -- 拔电(ac=false)→省电,插电→balanced
        end
    end
end
hl.timer(pollPower, { timeout = 3000, type = "repeat" })

-- ────────── 导航:胶带与工作区(WASD 十字) ──────────
-- 数字键:切换工作区
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. "+" .. key, hl.dsp.focus({ workspace = i }))
end
-- A/D:胶带左/右滚一列
hl.bind(mainMod .. "+A", hl.dsp.layout("move -col"))
hl.bind(mainMod .. "+D", hl.dsp.layout("move +col"))
-- W/S:上一个/下一个工作区(与 slidevert 动画方向一致;特殊工作区开着时在特殊区之间循环)
hl.bind(mainMod .. "+W", function() navWorkspace(-1) end)
hl.bind(mainMod .. "+S", function() navWorkspace(1) end)
-- 方向键:移动焦点
hl.bind(mainMod .. "+left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. "+right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. "+up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. "+down", hl.dsp.focus({ direction = "down" }))
-- 滚轮与侧键:工作区/胶带循环(裸侧键仍归应用;特殊工作区开着时滚轮在特殊区之间循环)
hl.bind(mainMod .. "+mouse_up", function() navWorkspace(-1) end)
hl.bind(mainMod .. "+mouse_down", function() navWorkspace(1) end)
hl.bind(mainMod .. "+mouse:276", hl.dsp.layout("move -col")) -- 侧键前=左滚
hl.bind(mainMod .. "+mouse:275", hl.dsp.layout("move +col")) -- 侧键后=右滚

-- ────────── 搬移(Super+Shift 系) ──────────
-- Shift+数字:窗口搬到对应工作区
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. "+SHIFT+" .. key, hl.dsp.window.move({ workspace = i }))
end
-- Shift+A/D:当前列与左/右列交换
hl.bind(mainMod .. "+SHIFT+A", hl.dsp.layout("swapcol l")) -- 当前列与左列交换
hl.bind(mainMod .. "+SHIFT+D", hl.dsp.layout("swapcol r")) -- 当前列与右列交换
-- Shift+W/S:将当前窗口移动到上一个/下一个工作区(与 W/S 同向;特殊区开着时扔到相邻特殊区)
hl.bind(mainMod .. "+SHIFT+W", function() moveWindowNav(-1) end)
hl.bind(mainMod .. "+SHIFT+S", function() moveWindowNav(1) end)
-- Shift+方向键:跨列/行移动窗口
hl.bind(mainMod .. "+SHIFT+left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. "+SHIFT+right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. "+SHIFT+up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. "+SHIFT+down", hl.dsp.window.move({ direction = "d" }))
-- Shift+滚轮与侧键:滚轮=窗口扔到下/上一个工作区(特殊区开着时扔到相邻特殊区);侧键前/后=与左/右列交换(与导航组鼠标成对)
hl.bind(mainMod .. "+SHIFT+mouse_down", function() moveWindowNav(1) end)
hl.bind(mainMod .. "+SHIFT+mouse_up", function() moveWindowNav(-1) end)
hl.bind(mainMod .. "+SHIFT+mouse:276", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. "+SHIFT+mouse:275", hl.dsp.layout("swapcol r"))

-- ────────── 多屏工作区调度(T / Shift+T / Ctrl+N) ──────────
-- 工作区保持全局编号,按需在各屏间搬运;单屏时全部自动 no-op
-- A: Super+T = 当前工作区整体搬到另一块屏(焦点跟随工作区过去;3屏时=顺序里的下一屏)
-- B: Super+Shift+T = 两屏的当前工作区整体对调(焦点不动,内容互换;3屏时只对调当前屏与下一屏,第三块不动)
-- C: Super+Ctrl+1~0 = 工作区 N 在多屏间循环迁移(从工作区自己所在的屏取下一块,与聚焦无关;不存在时无操作)
local function nextMonitor()
    local cur, names = hl.get_active_monitor(), {}
    for _, m in ipairs(hl.get_monitors()) do names[#names + 1] = m.name end
    for i, n in ipairs(names) do
        if n == cur.name then return names[i % #names + 1] end
    end
end
hl.bind(mainMod .. "+T", function()
    local o = nextMonitor()
    if o then hl.dispatch(hl.dsp.workspace.move({ monitor = o })) end
end)
hl.bind(mainMod .. "+SHIFT+T", function()
    local o = nextMonitor()
    if o then hl.dispatch(hl.dsp.workspace.swap_monitors({ monitor1 = hl.get_active_monitor().name, monitor2 = o })) end
end)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. "+CTRL+" .. key, function()
        local ws = hl.get_workspace(i)
        if not ws then return end
        local names = {}
        for _, m in ipairs(hl.get_monitors()) do names[#names + 1] = m.name end
        for idx, n in ipairs(names) do
            if n == ws.monitor.name then
                hl.dispatch(hl.dsp.workspace.move({ workspace = i, monitor = names[idx % #names + 1] }))
                return
            end
        end
    end)
end

-- ────────── 特殊工作区(special:magic) ──────────
hl.bind(mainMod .. "+Z", function() toggleSpecialNamed("magic") end) -- 特殊工作区
hl.bind(mainMod .. "+SHIFT+Z", hl.dsp.window.move({ workspace = "special:magic" }))
-- Super+V:特殊区层开关——开着则直接收起当前,没开则呼出最近使用的(不用先猜当前是哪个)
hl.bind(mainMod .. "+V", function() toggleSpecialLayer() end)
-- Super+中键:同 Super+V 的层开关(触控板上即 Super+三指轻点,clickfinger 三指点击=中键)
hl.bind(mainMod .. "+mouse:274", function() toggleSpecialLayer() end)
-- 两个补充的特殊工作区
hl.bind(mainMod .. "+X", function() toggleSpecialNamed("mofa") end) -- 特殊工作区
hl.bind(mainMod .. "+SHIFT+X", hl.dsp.window.move({ workspace = "special:mofa" }))
hl.bind(mainMod .. "+C", function() toggleSpecialNamed("maho") end) -- 特殊工作区
hl.bind(mainMod .. "+SHIFT+C", hl.dsp.window.move({ workspace = "special:maho" }))


-- ────────── 回跳与循环(窗口/工作区往返) ──────────
-- Super+Tab:跳回上一个聚焦的窗口(跨工作区跟随;再按弹回,天然 A/B 交替)
-- 用 Hyprland 自带的焦点历史(get_last_window),无需手动记录
hl.bind(mainMod .. "+TAB", function()
    local w = hl.get_last_window()
    if w == nil then return end
    if w.workspace ~= nil and not w.workspace.special then
        hl.dispatch(hl.dsp.focus({ workspace = w.workspace.id }))
    end
    hl.dispatch(hl.dsp.focus({ window = w }))
end)

-- ────────── 启动器(Alt 层) ──────────
hl.bind("ALT+T", hl.dsp.exec_cmd(terminal))              -- 终端
hl.bind("ALT+E", hl.dsp.exec_cmd(fileManager))           -- 文件管理器
hl.bind("ALT+R", hl.dsp.exec_cmd(menu))                  -- 应用启动器
hl.bind("ALT+B", hl.dsp.exec_cmd(browser))               -- 浏览器
hl.bind("ALT+C", hl.dsp.exec_cmd(coder))                 -- VS Code
hl.bind("ALT+V", hl.dsp.exec_cmd("walker -m clipboard")) -- 剪贴板历史
hl.bind("ALT+Q", hl.dsp.exec_cmd("walker -m windows"))   -- 窗口列表
hl.bind("ALT+ESCAPE", hl.dsp.exec_cmd("missioncenter"))  -- 任务管理器

-- ────────── 系统(锁屏/关闭) ──────────
hl.bind(mainMod .. "+L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. "+M",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

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

-- ────────── 截图与录制(Alt 层) ──────────
hl.bind("ALT+A", hl.dsp.exec_cmd("hyprshot -m region -z -o $HOME/Pictures/screenshot")) -- 区域截图(框选时画面冻结)
hl.bind("ALT+W", hl.dsp.exec_cmd("hyprshot -m window -o $HOME/Pictures/screenshot"))    -- 窗口截图
-- Alt+D:区域截图并钉住(swayimg 悬浮右下,文件存 /tmp 重启自清;看完 Super+Q 关)
-- 注:hyprshot 1.3 的截图在后台子进程完成,主进程退出码恒为 1(它自带的 -- command 也只支持无参命令),
-- 故不依赖退出码:打时间戳→截图→轮询 pin.png 是否更新(30s 超时,Esc 取消则不弹窗)
hl.bind("ALT+D", hl.dsp.exec_cmd(
    "touch /tmp/.pin_stamp; hyprshot -m region -s -z -o /tmp -f pin.png; i=0; until [ /tmp/pin.png -nt /tmp/.pin_stamp ] || [ $i -ge 100 ]; do sleep 0.3; i=$((i+1)); done; j=0; while [ -n \"$(pgrep -x grim)\" ] && [ $j -lt 50 ]; do sleep 0.2; j=$((j+1)); done; if [ /tmp/pin.png -nt /tmp/.pin_stamp ]; then eval set -- $(hyprctl monitors | awk '$1==\"Monitor\"{mon=$2} $1~/^[0-9]+x[0-9]+@/{match($1,/x/);x1=RSTART;match($1,/@/);x2=RSTART;pw=substr($1,1,x1-1);ph=substr($1,x1+1,x2-x1-1)} /scale:/{sc=$2} /transform:/{tr=$2} $1==\"focused:\"&&$2==\"yes\"{if(tr%2==1){print int(ph/sc),int(pw/sc),int(sc*1000)}else{print int(pw/sc),int(ph/sc),int(sc*1000)}}'); MW=$1; MH=$2; SCM=$3; set -- $(od -An -j 16 -N 8 -t u1 /tmp/pin.png); W=$(($1*16777216+$2*65536+$3*256+$4)); H=$(($5*16777216+$6*65536+$7*256+$8)); W=$(($W*1000/SCM)); H=$(($H*1000/SCM)); S=1000; [ $(($MW*800)) -lt $(($W*1000)) ] && S=$(($MW*800/$W)); [ $(($MH*800)) -lt $(($H*1000)) ] && [ $(($MH*800/$H)) -lt $S ] && S=$(($MH*800/$H)); swayimg -a pinshot -S $(($W*S/1000)),$(($H*S/1000)) /tmp/pin.png; fi"
))
-- OBS
hl.bind("ALT+F10", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" })) -- 暂停/恢复录制
hl.bind("ALT+F11", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" })) -- 开始录制
hl.bind("ALT+F12", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" })) -- 停止录制

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
local suppressMaximizeRule = hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})
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
-- 特殊工作区(边框颜色对应按键助记:magic(Z)=红 / mofa(X)=绿 / maho(C)=蓝,catppuccin 色板)
hl.window_rule({
    name    = "special-magic",
    match   = { workspace = "special:magic" },
    opacity = 0.9,
    border_color = "rgba(f38ba8dd)",
})
hl.window_rule({
    name    = "special-mofa",
    match   = { workspace = "special:mofa" },
    border_color = "rgba(a6e3a1dd)",
})
hl.window_rule({
    name    = "special-maho",
    match   = { workspace = "special:maho" },
    border_color = "rgba(89b4fadd)",
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
    name      = "better-control-float",
    match     = {
        initial_title = "Better Control"
    },
    float     = true,
    center    = true,
    size      = "monitor_w*0.3 monitor_h*0.6",
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
