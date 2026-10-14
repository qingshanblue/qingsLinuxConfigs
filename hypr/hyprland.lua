-- ═══════════════════════════════════════════════════════════════════════════
--  qings 的 Hyprland 配置(Lua/Hyprland 0.55+)
--  约定:注释统一写在对应代码的「上方」;快捷键主修饰键 mainMod = SUPER
--
--  段落顺序:
--    01 MONITORS          显示器
--    02 MY PROGRAMS       常用程序变量
--    03 AUTOSTART         开机自启
--    04 ENVIRONMENT       环境变量
--    05 PERMISSIONS       权限
--    06 LOOK AND FEEL     外观 / 动效
--    07 MISC              杂项
--    08 INPUT             键鼠 / 触控板
--    09 POWER             省电 / 性能模式(被快捷键引用的函数)
--    10 KEYBINDINGS       快捷键
--    11 GESTURES          触控板手势
--    12 WINDOWS & WORKSPACES  窗口 / 工作区规则
-- ═══════════════════════════════════════════════════════════════════════════


---------------------
----  MONITORS  ----
---------------------
-- 参考:https://wiki.hypr.land/Configuring/Basics/Monitors/

-- 内屏 eDP-1:最高刷新率,自动缩放
hl.monitor({
    output   = "eDP-1",
    mode     = "highrr",
    position = "0x0",
    scale    = "auto",
})
-- 备用内屏 eDP-2(暂未启用)
-- hl.monitor({
--     output   = "eDP-2",
--     mode     = "highrr",
--     position = "auto",
--     scale    = "auto",
-- })
-- 竖屏外接屏 DP-1(2560x1600@160Hz)
-- transform = 1 为 90° 旋转;若画面上下颠倒改成 3
-- position 放在主屏左侧、底边对齐(竖屏后高 2560,上边界远高于主屏)
hl.monitor({
    output    = "DP-1",
    mode      = "highrr",
    transform = 1,
    position  = "-1600x-0",
    scale     = 1.6,
})
-- HDMI-A-1:镜像内屏
hl.monitor({
    output   = "HDMI-A-1",
    mirror   = "eDP-1",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})


-------------------------
----  MY PROGRAMS  ----
-------------------------
-- 供下面 hl.bind / hl.window_rule 引用的程序变量

-- 终端
local terminal    = "kitty"
-- 文件管理器
local fileManager = "nemo"
-- 应用启动器 / 搜索
local menu        = "walker"
-- 浏览器
local browser     = "google-chrome-stable"
-- 图片查看器
local imageViewr  = "swayimg"
-- 视频播放器
local videoViewr  = "Celluloid"
-- 通知守护
local notifier    = "swaync"
-- 代码编辑器
local coder       = "code"
-- 压缩包管理器
local archiver    = "ark"
-- 状态栏
local statusBar   = "waybar"
-- 壁纸
local wallpaper   = "hyprpaper"


----------------------
----  AUTOSTART  ----
----------------------
-- 参考:https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    -- 状态栏
    hl.exec_cmd(statusBar)
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


-------------------------------
----  ENVIRONMENT VARS  ----
-------------------------------
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
hl.env("GDK_SCALE", "2")
hl.env("QT_SCALE_FACTOR", "1.6")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
-- 代理
-- local proxy_host = "192.168.6.5:20122"  -- 局域网备选
local proxy_host = "127.0.0.1:20122"
hl.env("http_proxy", "http://" .. proxy_host)
hl.env("https_proxy", "http://" .. proxy_host)
hl.env("all_proxy", "socks5://" .. proxy_host)
hl.env("no_proxy", "localhost,127.0.0.1,::1")


-----------------------
----  PERMISSIONS  ----
-----------------------
-- 参考:https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- (当前未配置任何权限规则)


-----------------------
----  LOOK AND FEEL  ----
-----------------------
hl.config({
    general = {
        gaps_in  = 4,
        -- 外围留多点呼吸感,窗口像"悬浮卡片"
        gaps_out = 12,
        -- 想让渐变更显眼可以试 3
        border_size = 2,
        col = {
            -- 常规工作区 = 紫→粉渐变(备选:黄 f9e2af / 琥珀 e5c890 / 暖白 f5e0dc)
            active_border = {
                colors = { "rgba(cba6f7ee)", "rgba(f5c2e7ee)" },
                angle  = 45
            },
            inactive_border = "rgba(8fb2c9aa)",
        },
        resize_on_border = false,
        allow_tearing    = false,
        -- 无限平铺;想回老手感改回 "dwindle"
        layout = "scrolling",
    },
    decoration = {
        rounding       = 12,
        rounding_power = 2,
        active_opacity = 0.95,
        -- 拉大聚焦对比
        inactive_opacity = 0.80,
        shadow = {
            enabled = true,
            -- 大而柔的阴影比小硬阴影更有悬浮感
            range        = 20,
            render_power = 4,
            -- 带一点蓝调的黑,更柔和
            color = 0xcc1a1a26,
        },
        blur = {
            enabled = true,
            -- 3→8,模糊才看得出来
            size   = 8,
            -- 2 遍 + 大 size = 真正的磨砂玻璃
            passes = 2,
            vibrancy = 0.1696,
            -- 下面三个是经典"奶玻璃"配方
            contrast   = 0.8916,
            brightness = 0.8172,
            noise      = 0.0117,
        },
    },
    animations = { enabled = true },
})

-- 自定义曲线
-- snappy:窗口开合(想要更弹就换成 bouncy)
hl.curve("snappy", { type = "spring", mass = 1, stiffness = 230, dampening = 26 })
-- bouncy:更弹的弹簧
hl.curve("bouncy", { type = "spring", mass = 1, stiffness = 300, dampening = 22 })
-- easeOutQuint:标准缓出曲线
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1 } } })

-- 窗口开合更有生命感
hl.animation({ leaf = "windows", enabled = true, speed = 4, spring = "snappy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.4, spring = "snappy", style = "popin 85%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.6, bezier = "linear", style = "popin 85%" })
-- 工作区切换:垂直滑动动画,配合三指上下滑切工作区的方向感
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "easeOutQuint", style = "slidevert" })
-- 特殊工作区从底部滑入(不显式写的话会继承 workspaces 的动画,这里固定下来)
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.5, bezier = "easeOutQuint", style = "slidevert" })
-- 渐变边框流动动画:loop 模式会持续重绘导致 VFR 完全失效(空闲时 GPU/CPU 也常驻工作),为续航关闭;想要流动效果改回 enabled = true
-- hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "linear", style = "loop" })

-- 参考:https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
hl.config({ scrolling = { fullscreen_on_one_column = true } })


--------------
----  MISC  ----
--------------
-- vfr(变帧率)默认即为 true,无需显式声明;此前 borderangle 常驻动画已关,VFR 现在能真正生效
hl.config({
    misc = {
        -- 设为 0 或 1 可禁用自带动漫壁纸
        force_default_wallpaper = -1,
        -- 关掉随机 hyprland logo / 动漫背景
        disable_hyprland_logo = true,
    },
})


---------------
----  INPUT  ----
---------------
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        follow_mouse = 1,
        -- -1.0 ~ 1.0,0 表示不做修改
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
            scroll_factor  = 0.33,
            -- 按指头数点击:1 指=左键,2 指=右键,3 指=中键(替代右下角软按钮区)
            clickfinger_behavior = true
        },
    },
})


---------------
----  POWER  ----
---------------
-- 电源模式与档位收敛:
--   架构:ppd 档位 = 唯一事实源,特效作跟随者:
--     快捷键 powerMode() = 写档位 + 立即 applyVisuals;hl.timer 每 3s 轮询(sysfs 纯文件读):
--     ① EPP → 任何入口(better-control/CLI)改档位,特效 ≤3s 跟随;开机/重载首拍静默同步
--     ② AC 在线状态 → 插电=performance,断电=power-saver(边沿触发,首拍只建档)
--     ③ 电量检测 → ≤15% 提醒,≤10% 先挂起,≤5% 落盘休眠(仅放电中触发;每级每周期一次)
--   映射:epp=power → 省电视效;其余 → 性能视效。timer 只读不写档位,不会与 better-control 打架
--   省电模式:关动画/blur/阴影,内屏 60Hz,并让所有窗口完全不透明
--   注意:恢复侧 0.95/0.80 需与上方 decoration 配置同步修改
local lastPerf = nil

-- 需要在省电模式下关闭的「按窗口透明度」规则(由下方 WINDOWS AND WORKSPACES 段注册进来)
-- 省电时关掉它们,窗口就回落到 decoration 的 1.0 → 全部不透明
local dimRules = {}

-- 应用性能/省电视效;notify=false 时不弹通知(用于开机/重载首拍静默同步)
local function applyVisuals(perf, notify)
    lastPerf = perf
    -- 性能模式启用按窗口透明度;省电模式关闭 → 全部不透明
    for _, r in ipairs(dimRules) do
        if r ~= nil then
            pcall(function() r:set_enabled(perf) end)
        end
    end
    hl.config({
        animations = { enabled = perf },
        decoration = {
            active_opacity   = perf and 0.95 or 1,
            inactive_opacity = perf and 0.80 or 1,
            shadow = { enabled = perf },
            blur   = { enabled = perf },
        },
    })
    -- 内屏刷新率随之切换
    hl.monitor({ output = "eDP-1", mode = perf and "2560x1440@165" or "2560x1440@60", position = "0x0", scale = 1.6 })
    if notify ~= false then
        hl.notification.create({
            text     = perf and "性能模式:特效全开 · 165Hz" or "省电模式:特效已关 · 60Hz",
            duration = 2500,
            color    = perf and "rgb(a6e3a1)" or "rgb(f9e2af)",
        })
    end
end

-- 切换 ppd 档位并立即应用视效
-- 插电(perf=true)→ performance(不支持 performance 的机器回退 balanced);断电 → power-saver
local function powerMode(perf)
    if perf then
        hl.exec_cmd("powerprofilesctl set performance || powerprofilesctl set balanced")
    else
        hl.exec_cmd("powerprofilesctl set power-saver")
    end
    applyVisuals(perf)
end

-- 轮询①:档位 → 特效收敛(仅状态变化时动作,首拍静默同步)
local function syncVisuals()
    local f = io.open("/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference", "r")
    if not f then return end
    local epp = f:read("*l")
    f:close()
    local perf = (epp ~= "power")
    if perf ~= lastPerf then applyVisuals(perf, lastPerf ~= nil) end
end

-- 轮询②:AC 插拔自动切档(边沿触发;首拍只建档不动作,boot 档位交由 ppd/用户)
-- 注意:插拔边沿会覆盖手动选择(拔电必进 power-saver / 插电必进 performance),标准笔记本语义
local lastAc = nil

-- 读取 AC 在线状态;取不到返回 nil
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

-- ── 电量检测:低电提醒 / 先挂起 / 落盘休眠 ──
-- 阈值(%),低于且在放电中时触发:
local BAT_WARN = 15       -- 低电提醒
local BAT_SUSPEND = 10    -- 先挂起(suspend-then-hibernate);系统在 ≤5% 或 HibernateDelaySec 后自动落盘
local BAT_HIBERNATE = 5   -- 直接落盘休眠
-- 动作命令(失败时逐级回退)
local SUSPEND_CMD   = "systemctl suspend-then-hibernate || systemctl suspend"
local HIBERNATE_CMD = "systemctl hibernate || systemctl suspend-then-hibernate || systemctl suspend"
-- 电池路径候选(避免在回调里 fork 扫描目录,依次取第一个可用)
local BAT_CANDIDATES = {
    "/sys/class/power_supply/BAT0",
    "/sys/class/power_supply/BAT1",
    "/sys/class/power_supply/BAT2",
    "/sys/class/power_supply/BAT",
}

-- 读取第一个可用电池的电量(%)与充电状态;无电池返回 nil, nil
local function readBattery()
    for _, base in ipairs(BAT_CANDIDATES) do
        local fc = io.open(base .. "/capacity", "r")
        if fc then
            local cap = tonumber(fc:read("*l"))
            fc:close()
            local status = "Unknown"
            local fs = io.open(base .. "/status", "r")
            if fs then
                status = fs:read("*l") or "Unknown"
                fs:close()
            end
            return cap, status
        end
    end
    return nil, nil
end

-- 每个放电周期只告警一次 + 只采取一次紧急动作;插电或充电时重置
local batWarned, batActed = false, false

-- 低电检测;ac = AC 在线状态(true 插电 / false 断电 / nil 未知)
local function checkBattery(ac)
    local cap, status = readBattery()
    -- 无电池(台式机)直接跳过
    if cap == nil then return end
    -- 是否放电中:优先看 AC,再看电池 status(充电 / 满电都算非放电)
    local onBattery
    if ac ~= nil then
        onBattery = (ac == false) and (status ~= "Charging" and status ~= "Full")
    else
        onBattery = (status == "Discharging")
    end
    if not onBattery then
        batWarned, batActed = false, false
        return
    end
    -- ≤5%:直接落盘休眠(冷启动/兜底;正常路径下这一步由 systemd 在挂起中完成)
    if cap <= BAT_HIBERNATE and not batActed then
        batActed, batWarned = true, true
        hl.notification.create({
            text     = string.format("电量仅 %d%%,即将休眠落盘", cap),
            duration = 5000,
            color    = "rgb(f38ba8)",
        })
        hl.exec_cmd(HIBERNATE_CMD)
        return
    end
    -- ≤10%:先挂起(suspend-then-hibernate);系统在 ≤5% 或 HibernateDelaySec 后自动落盘
    -- 与上面共用 batActed:避免休眠恢复后立刻再次触发(否则恢复后 3s 内又会睡下去)
    if cap <= BAT_SUSPEND and not batActed then
        batActed, batWarned = true, true
        hl.notification.create({
            text     = string.format("电量 %d%%,即将挂起待休眠", cap),
            duration = 5000,
            color    = "rgb(fab387)",
        })
        hl.exec_cmd(SUSPEND_CMD)
        return
    end
    -- ≤15%:低电提醒(仅一次)
    if cap <= BAT_WARN and not batWarned then
        batWarned = true
        hl.notification.create({
            text     = string.format("电量偏低 %d%%,请及时充电", cap),
            duration = 5000,
            color    = "rgb(f9e2af)",
        })
    end
end

local function pollPower()
    syncVisuals()
    local ac = acOnline()
    -- 低电检测(低于阈值且放电中 → 提醒 / 休眠)
    checkBattery(ac)
    if ac ~= nil then
        if lastAc == nil then
            lastAc = ac
        elseif ac ~= lastAc then
            lastAc = ac
            -- 拔电(ac=false)→ power-saver,插电 → performance
            powerMode(ac)
        end
    end
end

-- 每 3s 轮询一次
hl.timer(pollPower, { timeout = 3000, type = "repeat" })


-----------------------
----  KEYBINDINGS  ----
-----------------------
-- 主修饰键:SUPER(Windows 键)
local mainMod = "SUPER"

-- ═══ 特殊工作区辅助逻辑(供下面快捷键/手势共用)═══

-- 三个特殊工作区的顺序(用于循环)
local specialOrder = { "magic", "mofa", "maho" }
-- 最近使用的特殊工作区(呼出类操作的目标)
local lastSpecial = "magic"

-- 把"最近使用的特殊区"镜像到文件,供 waybar 魔法棒/外部读取(waybar 左键 = Super+` 的语义)
local LAST_SPECIAL_FILE = "/dev/shm/hypr-last-special"
local function rememberSpecial(name)
    lastSpecial = name
    local f = io.open(LAST_SPECIAL_FILE, "w")
    if f then
        f:write(name)
        f:close()
    end
end

-- 从工作区对象/字符串里取出特殊区名(去掉 "special:" 前缀);取不到返回 nil
local function specialNameOf(ws)
    if ws == nil then return nil end
    local name
    if type(ws) == "string" then
        name = ws
    else
        -- 实测返回 userdata(HL.Workspace 对象),属性经 __index 暴露;多重兜底防 API 差异
        local ok, n = pcall(function() return ws.name end)
        if ok and n ~= nil then
            name = tostring(n)
        else
            -- 兜底:从 "HL.Workspace(-97:special:mofa)" 里提取 mofa
            name = tostring(ws):match("special:([%w_%-]+)")
        end
    end
    if name ~= nil then name = name:gsub("^special:", "") end
    return name
end

-- 当前(聚焦屏)激活的特殊区名;没开则返回 nil
local function getActiveSpecialName()
    return specialNameOf(hl.get_active_special_workspace())
end

-- 找到正在显示特殊区 name 的显示器对象;没有则返回 nil
local function specialHolder(name)
    for _, m in ipairs(hl.get_monitors()) do
        local sp = m.active_special_workspace
        if sp ~= nil and specialNameOf(sp) == name then
            return m
        end
    end
    return nil
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

-- 让特殊区 name "出现并聚焦":已在别的屏 → 聚焦那屏;否则在当前屏打开
local function activateSpecial(name)
    local cur = hl.get_active_monitor()
    local holder = specialHolder(name)
    if holder ~= nil and holder.name ~= cur.name then
        hl.dispatch(hl.dsp.focus({ monitor = holder.name }))
    else
        hl.dispatch(hl.dsp.workspace.toggle_special(name))
    end
    rememberSpecial(name)
end

-- 点名/层开关:已在当前屏 → 关闭;已在别的屏 → 聚焦那屏;都没开 → 当前屏打开
local function invokeSpecial(name)
    local cur = hl.get_active_monitor()
    local holder = specialHolder(name)
    if holder ~= nil and holder.name == cur.name then
        -- 当前屏已开 → 关闭(不改"最近使用")
        hl.dispatch(hl.dsp.workspace.toggle_special(name))
        return
    end
    rememberSpecial(name)
    if holder ~= nil then
        hl.dispatch(hl.dsp.focus({ monitor = holder.name }))
    else
        hl.dispatch(hl.dsp.workspace.toggle_special(name))
    end
end

-- 切工作区:dir=1 下一个,-1 上一个。有特殊区开着时在 magic/mofa/maho 之间循环;未开时切常规工作区
local function navWorkspace(dir)
    local cur = getActiveSpecialName()
    if cur == nil then
        if dir == 1 then
            -- 常规:下一个工作区
            hl.dispatch(hl.dsp.focus({ workspace = "e+1" }))
        else
            -- 常规:上一个工作区
            hl.dispatch(hl.dsp.focus({ workspace = "e-1" }))
        end
        return
    end
    local nxt = adjacentSpecial(cur, dir)
    if nxt == nil then return end
    activateSpecial(nxt)
end

-- 扔窗口:有特殊区开着时扔到相邻特殊区(人跟过去);未开时扔到相邻常规工作区
local function moveWindowNav(dir)
    local cur = getActiveSpecialName()
    if cur == nil then
        if dir == 1 then
            -- 常规:下一个工作区
            hl.dispatch(hl.dsp.window.move({ workspace = "e+1" }))
        else
            -- 常规:上一个工作区
            hl.dispatch(hl.dsp.window.move({ workspace = "e-1" }))
        end
        return
    end
    local nxt = adjacentSpecial(cur, dir)
    if nxt == nil then return end
    -- 先让目标特殊区出现/聚焦(已在别屏则聚焦那屏),再把窗口移进去
    activateSpecial(nxt)
    hl.dispatch(hl.dsp.window.move({ workspace = "special:" .. nxt }))
end

-- 点名 toggle(Z/X/C 用)
local function toggleSpecialNamed(name)
    invokeSpecial(name)
end

-- 特殊区层开关:当前屏开着则收起;否则呼出最近使用的(已在别屏则聚焦那屏)
local function toggleSpecialLayer()
    local cur = getActiveSpecialName()
    if cur ~= nil then
        hl.dispatch(hl.dsp.workspace.toggle_special(cur))
    else
        invokeSpecial(lastSpecial)
    end
end

-- ═══ 窗口状态(浮动 / 全屏 / 钉住 + 鼠标拖拽)═══

-- 关闭窗口
hl.bind(mainMod .. "+Q", hl.dsp.window.close())
-- 窗口浮动切换
hl.bind(mainMod .. "+F", hl.dsp.window.float({ action = "toggle" }))
-- 钉住浮动窗口(固定显示在所有工作区)
hl.bind(mainMod .. "+CTRL+F", hl.dsp.window.pin({ action = "toggle" }))
-- 全屏切换(scrolling 布局下可滚走,回来还是全屏)
hl.bind(mainMod .. "+SHIFT+F", hl.dsp.window.fullscreen({ action = "toggle" }))
-- 拖动窗口(Super + 左键)
hl.bind(mainMod .. "+mouse:272", hl.dsp.window.drag(), { mouse = true })
-- 调整窗口大小(Super + 右键)
hl.bind(mainMod .. "+mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ═══ 布局调整(列与视野)═══

-- 列宽循环:0.33 / 0.5 / 0.667 / 1.0(高频)
hl.bind(mainMod .. "+R", hl.dsp.layout("colresize +conf"))
-- 独列 ↔ 并入右列(窗口上下排 ↔ 并排)
hl.bind(mainMod .. "+SHIFT+R", hl.dsp.layout("consume_or_expel next"))
-- 锁定/解锁视野自动滚动
hl.bind(mainMod .. "+CTRL+R", hl.dsp.layout("inhibit_scroll"))

-- ═══ 导航:胶带与工作区(WASD 十字)═══

-- 数字键 1-0:切换工作区
for i = 1, 10 do
    -- 10 映射到数字键 0
    local key = i % 10
    hl.bind(mainMod .. "+" .. key, hl.dsp.focus({ workspace = i }))
end
-- 胶带左滚一列
hl.bind(mainMod .. "+A", hl.dsp.layout("move -col"))
-- 胶带右滚一列
hl.bind(mainMod .. "+D", hl.dsp.layout("move +col"))
-- 上一个工作区(与 slidevert 动画方向一致;特殊区开着时在特殊区之间循环)
hl.bind(mainMod .. "+W", function() navWorkspace(-1) end)
-- 下一个工作区
hl.bind(mainMod .. "+S", function() navWorkspace(1) end)
-- 方向键:移动焦点
hl.bind(mainMod .. "+left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. "+right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. "+up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. "+down", hl.dsp.focus({ direction = "down" }))
-- 滚轮:上/下一个工作区(裸侧键仍归应用;特殊区开着时在特殊区之间循环)
hl.bind(mainMod .. "+mouse_up", function() navWorkspace(-1) end)
hl.bind(mainMod .. "+mouse_down", function() navWorkspace(1) end)
-- 鼠标侧键前:左滚一列
hl.bind(mainMod .. "+mouse:276", hl.dsp.layout("move -col"))
-- 鼠标侧键后:右滚一列
hl.bind(mainMod .. "+mouse:275", hl.dsp.layout("move +col"))

-- ═══ 搬移(Super+Shift 系)═══

-- Shift + 数字:窗口搬到对应工作区
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. "+SHIFT+" .. key, hl.dsp.window.move({ workspace = i }))
end
-- 当前列与左列交换
hl.bind(mainMod .. "+SHIFT+A", hl.dsp.layout("swapcol l"))
-- 当前列与右列交换
hl.bind(mainMod .. "+SHIFT+D", hl.dsp.layout("swapcol r"))
-- 将当前窗口移动到上一个工作区(与 W/S 同向;特殊区开着时扔到相邻特殊区)
hl.bind(mainMod .. "+SHIFT+W", function() moveWindowNav(-1) end)
-- 将当前窗口移动到下一个工作区
hl.bind(mainMod .. "+SHIFT+S", function() moveWindowNav(1) end)
-- Shift+方向键:跨列/行移动窗口
hl.bind(mainMod .. "+SHIFT+left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. "+SHIFT+right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. "+SHIFT+up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. "+SHIFT+down", hl.dsp.window.move({ direction = "d" }))
-- Shift+滚轮:窗口扔到上/下一个工作区(特殊区开着时扔到相邻特殊区)
hl.bind(mainMod .. "+SHIFT+mouse_down", function() moveWindowNav(1) end)
hl.bind(mainMod .. "+SHIFT+mouse_up", function() moveWindowNav(-1) end)
-- Shift+侧键前/后:与左/右列交换(与导航组鼠标成对)
hl.bind(mainMod .. "+SHIFT+mouse:276", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. "+SHIFT+mouse:275", hl.dsp.layout("swapcol r"))

-- ═══ 特殊工作区(scratchpad:magic / mofa / maho)═══

-- 层开关:开着则直接收起当前,没开则呼出最近使用的(不用先猜当前是哪个)
hl.bind(mainMod .. "+GRAVE", function() toggleSpecialLayer() end)
-- Super + 中键:同 Super+` 的层开关(触控板上即 Super+三指轻点,clickfinger 三指点击=中键)
hl.bind(mainMod .. "+mouse:274", function() toggleSpecialLayer() end)
-- magic(Z):开合
hl.bind(mainMod .. "+Z", function() toggleSpecialNamed("magic") end)
-- magic(Z):把窗口扔进去
hl.bind(mainMod .. "+SHIFT+Z", hl.dsp.window.move({ workspace = "special:magic" }))
-- mofa(X):开合
hl.bind(mainMod .. "+X", function() toggleSpecialNamed("mofa") end)
-- mofa(X):把窗口扔进去
hl.bind(mainMod .. "+SHIFT+X", hl.dsp.window.move({ workspace = "special:mofa" }))
-- maho(C):开合
hl.bind(mainMod .. "+C", function() toggleSpecialNamed("maho") end)
-- maho(C):把窗口扔进去
hl.bind(mainMod .. "+SHIFT+C", hl.dsp.window.move({ workspace = "special:maho" }))

-- ═══ 回跳(窗口往返)═══

-- Super+Tab:跳到"最近的、非特殊工作区"的窗口(特殊区不计入;再按弹回,A/B 交替)
-- 自行扫描窗口的 focus_history_id(0=最近聚焦)筛选,不依赖 get_last_window
hl.bind(mainMod .. "+TAB", function()
    local cur = hl.get_active_window()
    local best, bestId = nil, nil
    for _, w in ipairs(hl.get_windows()) do
        local ws = w.workspace
        if ws ~= nil and not ws.special and (cur == nil or w.address ~= cur.address) then
            local id = w.focus_history_id
            if id ~= nil and id >= 0 and (bestId == nil or id < bestId) then
                best, bestId = w, id
            end
        end
    end
    if best == nil then return end
    if best.workspace ~= nil then
        hl.dispatch(hl.dsp.focus({ workspace = best.workspace.id }))
    end
    hl.dispatch(hl.dsp.focus({ window = best }))
end)

-- ═══ 多屏工作区调度(G / Shift+G / Ctrl+数字)═══
-- 工作区保持全局编号,按需在各屏间搬运;单屏时全部自动 no-op

-- nextMonitor():返回显示器顺序里的下一块屏
local function nextMonitor()
    local cur, names = hl.get_active_monitor(), {}
    for _, m in ipairs(hl.get_monitors()) do names[#names + 1] = m.name end
    for i, n in ipairs(names) do
        if n == cur.name then return names[i % #names + 1] end
    end
end
-- 当前工作区整体搬到另一块屏(焦点跟随工作区过去;3 屏时 = 顺序里的下一屏)
hl.bind(mainMod .. "+G", function()
    local o = nextMonitor()
    if o then hl.dispatch(hl.dsp.workspace.move({ monitor = o })) end
end)
-- 两屏的当前工作区整体对调(焦点不动,内容互换;3 屏时只对调当前屏与下一屏,第三块不动)
hl.bind(mainMod .. "+SHIFT+G", function()
    local o = nextMonitor()
    if o then hl.dispatch(hl.dsp.workspace.swap_monitors({ monitor1 = hl.get_active_monitor().name, monitor2 = o })) end
end)
-- Super+Ctrl+1~0:工作区 N 在多屏间循环迁移(从工作区自己所在的屏取下一块,与聚焦无关;不存在时无操作)
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

-- ═══ 应用启动(常用软件单键 + walker)═══

-- 应用启动器:Super+Space 归 fcitx 切输入法、Ctrl+Space 打游戏会用,故用 Alt+Space
hl.bind("ALT+SPACE", hl.dsp.exec_cmd(menu))
-- 终端
hl.bind(mainMod .. "+T", hl.dsp.exec_cmd(terminal))
-- 浏览器
hl.bind(mainMod .. "+B", hl.dsp.exec_cmd(browser))
-- 剪贴板历史
hl.bind(mainMod .. "+V", hl.dsp.exec_cmd("walker -m clipboard"))
-- 文件管理器
hl.bind(mainMod .. "+E", hl.dsp.exec_cmd(fileManager))
-- VS Code
hl.bind(mainMod .. "+H", hl.dsp.exec_cmd(coder))
-- 任务管理器
hl.bind(mainMod .. "+ESCAPE", hl.dsp.exec_cmd("missioncenter"))

-- ═══ 系统(电源 / 锁屏 / 关闭)═══

-- 进省电:动画/blur/阴影关,不透明,60Hz,CPU→power-saver
hl.bind(mainMod .. "+CTRL+P", function() powerMode(false) end)
-- 回性能:特效全开,165Hz,CPU→balanced
hl.bind(mainMod .. "+CTRL+SHIFT+P", function() powerMode(true) end)
-- 锁屏
hl.bind(mainMod .. "+L", hl.dsp.exec_cmd("hyprlock"))
-- 退出(有 hyprshutdown 就用它,否则退回 hyprctl exit)
hl.bind(mainMod .. "+M",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- ═══ 多媒体与功能键(笔记本)═══

-- 音量 +(上限 100%)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
-- 音量 -
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
-- 输出静音开关
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true })
-- 麦克风静音开关
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true })
-- 亮度 +
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
-- 亮度 -
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
-- 下一曲(需 playerctl)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
-- 播放/暂停
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- 播放/暂停
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- 上一曲
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- ═══ 截图与录制 ═══

-- 区域截图(框选时画面冻结)
hl.bind(mainMod .. "+CTRL+A", hl.dsp.exec_cmd("hyprshot -m region -z -o $HOME/Pictures/screenshot"))
-- 窗口截图
hl.bind(mainMod .. "+CTRL+S", hl.dsp.exec_cmd("hyprshot -m window -o $HOME/Pictures/screenshot"))
-- 区域截图并钉住(swayimg 悬浮,文件存 /tmp 重启自清;看完 Super+Q 关)
-- 注:hyprshot 1.3 的截图在后台子进程完成,主进程退出码恒为 1(它自带的 -- command 也只支持无参命令),
-- 故不依赖退出码:打时间戳 → 截图 → 轮询 pin.png 是否更新(30s 超时,Esc 取消则不弹窗)
hl.bind(mainMod .. "+CTRL+D", hl.dsp.exec_cmd(
    "touch /tmp/.pin_stamp; hyprshot -m region -s -z -o /tmp -f pin.png; i=0; until [ /tmp/pin.png -nt /tmp/.pin_stamp ] || [ $i -ge 100 ]; do sleep 0.3; i=$((i+1)); done; j=0; while [ -n \"$(pgrep -x grim)\" ] && [ $j -lt 50 ]; do sleep 0.2; j=$((j+1)); done; if [ /tmp/pin.png -nt /tmp/.pin_stamp ]; then eval set -- $(hyprctl monitors | awk '$1==\"Monitor\"{mon=$2} $1~/^[0-9]+x[0-9]+@/{match($1,/x/);x1=RSTART;match($1,/@/);x2=RSTART;pw=substr($1,1,x1-1);ph=substr($1,x1+1,x2-x1-1)} /scale:/{sc=$2} /transform:/{tr=$2} $1==\"focused:\"&&$2==\"yes\"{if(tr%2==1){print int(ph/sc),int(pw/sc),int(sc*1000)}else{print int(pw/sc),int(ph/sc),int(sc*1000)}}'); MW=$1; MH=$2; SCM=$3; set -- $(od -An -j 16 -N 8 -t u1 /tmp/pin.png); W=$(($1*16777216+$2*65536+$3*256+$4)); H=$(($5*16777216+$6*65536+$7*256+$8)); W=$(($W*1000/SCM)); H=$(($H*1000/SCM)); S=1000; [ $(($MW*800)) -lt $(($W*1000)) ] && S=$(($MW*800/$W)); [ $(($MH*800)) -lt $(($H*1000)) ] && [ $(($MH*800/$H)) -lt $S ] && S=$(($MH*800/$H)); swayimg -a pinshot -S $(($W*S/1000)),$(($H*S/1000)) /tmp/pin.png; fi"
))
-- OBS:暂停/恢复录制
hl.bind(mainMod .. "+F10", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" }))
-- OBS:开始录制
hl.bind(mainMod .. "+F11", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" }))
-- OBS:停止录制
hl.bind(mainMod .. "+F12", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" }))


------------------------
----  GESTURES  ----
------------------------
-- 适配 scrolling 布局

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
-- 三指左右滑:跟手滚动胶带(轴向一致,行程也长)
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
-- 三指上下滑:切换工作区(特殊区开着时在三个特殊区之间循环;上滑=下一个,下滑=上一个,与旧内置手势同向)
local gy3 = 0
hl.gesture({
    fingers   = 3,
    direction = "vertical",
    action    = {
        start  = function() gy3 = 0 end,
        update = function(e) gy3 = gy3 + e.delta.y end,
        finish = function()
            if gy3 < -40 then
                -- 上滑:下一个
                navWorkspace(1)
            elseif gy3 > 40 then
                -- 下滑:上一个
                navWorkspace(-1)
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
                -- 上滑:上一个
                moveWindowNav(-1)
            elseif ws_dy > 40 then
                -- 下滑:下一个
                moveWindowNav(1)
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


--------------------------------
----  WINDOWS AND WORKSPACES  ----
--------------------------------
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
-- 特殊工作区边框色(与按键助记对应:magic(Z)=红 / mofa(X)=绿 / maho(C)=蓝,catppuccin 色板)
hl.window_rule({
    name         = "special-magic",
    match        = { workspace = "special:magic" },
    border_color = "rgba(f38ba8dd)",
})
hl.window_rule({
    name         = "special-mofa",
    match        = { workspace = "special:mofa" },
    border_color = "rgba(a6e3a1dd)",
})
hl.window_rule({
    name         = "special-maho",
    match        = { workspace = "special:maho" },
    border_color = "rgba(89b4fadd)",
})
-- 特殊工作区半透明(仅性能模式;省电模式由 dimRules 关掉 → 不透明)
table.insert(dimRules, hl.window_rule({
    name    = "special-magic-dim",
    match   = { workspace = "special:magic" },
    opacity = 0.9,
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
-- 终端:略透明(仅性能模式;省电模式由 dimRules 关掉 → 不透明)
table.insert(dimRules, hl.window_rule({
    name    = "terminal-dim",
    match   = { class = "^.*(?i)" .. terminal .. ".*$" },
    opacity = 0.85,
}))
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
    match  = { class = "^.*(?i)" .. archiver .. ".*$" },
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
    name   = "motrix-next-float",
    match  = { initial_class = "motrix-next" },
    float  = true,
    center = true,
    size   = "monitor_w*0.3 monitor_h*0.7"
})
