-- 省电 / 性能模式 (POWER):返回 powerMode 与 dimRules 供其他模块使用

-- 电源模式与档位收敛:
--   架构:ppd 档位 = 唯一事实源,特效作跟随者:
--     快捷键 powerMode() = 写档位 + 立即 applyVisuals;hl.timer 每 3s 轮询(sysfs 纯文件读):
--     ① EPP → 任何入口(better-control/CLI)改档位,特效 ≤3s 跟随;开机/重载首拍静默同步
--     ② AC 在线状态 → 插电=performance,断电=power-saver(边沿触发;首拍按当前 AC 状态静默对齐)
--     ③ 电量检测 → ≤15% 提醒,≤10% 先挂起,≤5% 落盘休眠(仅放电中触发;每级每周期一次)
--   映射:epp=power → 省电视效;其余 → 性能视效。timer 只读不写档位,不会与 better-control 打架
--   省电模式:关动画/blur/阴影,内屏 60Hz,并让所有窗口完全不透明
--   注意:恢复侧 0.96/0.84 需与上方 decoration 配置同步修改
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
            active_opacity   = perf and 0.96 or 1,
            inactive_opacity = perf and 0.84 or 1,
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
local function powerMode(perf, notify)
    if perf then
        hl.exec_cmd("powerprofilesctl set performance || powerprofilesctl set balanced")
    else
        hl.exec_cmd("powerprofilesctl set power-saver")
    end
    applyVisuals(perf, notify)
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

-- 轮询②:AC 插拔自动切档(边沿触发;首拍(开机/重载)按当前 AC 状态静默对齐一次)
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
    local ac = acOnline()
    -- 首拍(开机 / 重载):按当前电源状态强制对齐一次档位与特效,静默不弹通知
    if ac ~= nil and lastAc == nil then
        lastAc = ac
        powerMode(ac, false)
    else
        syncVisuals()
        if ac ~= nil and ac ~= lastAc then
            lastAc = ac
            -- 拔电(ac=false)→ power-saver,插电 → performance
            powerMode(ac)
        end
    end
    -- 低电检测(低于阈值且放电中 → 提醒 / 休眠)
    checkBattery(ac)
end

-- 每 3s 轮询一次
hl.timer(pollPower, { timeout = 3000, type = "repeat" })

return {
    powerMode = powerMode,
    dimRules  = dimRules,
}
