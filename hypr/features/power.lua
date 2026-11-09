-- 电源与能效管理 (POWER & ENERGY)
-- 架构: ppd 档位为唯一事实源, 特效随之跟随
-- ① EPP 轮询: 任何入口改动档位，视效 ≤3s 自动跟随；首拍静默同步
-- ② AC 在线状态: 插电切换性能模式，断电切换省电模式
-- ③ 电池电量梯级防护:
--    - ≤15%: 桌面通知告警
--    - ≤10%: 挂起后休眠 (suspend-then-hibernate)
--    - ≤ 5%: 紧急落盘休眠 (hibernate)
-- 导出接口: powerMode (供快捷键调用), dimRules (供 rules.lua 注册受控透明规则)

local lastPerf = nil

-- 需要在省电模式下关闭的「按窗口透明度」规则列表 (由 apps/rules.lua 注册进来)
-- 省电时禁用它们, 窗口透明度回落至 decoration 的 1.0 (全不透明)
local dimRules = {}

-- 应用视效 (性能 vs 省电)
local function applyVisuals(perf, notify)
    lastPerf = perf
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
    -- 内屏刷新率同步切换
    hl.monitor({ output = "eDP-1", mode = perf and "2560x1440@165" or "2560x1440@60", position = "0x0", scale = 1.6 })
    if notify ~= false then
        hl.notification.create({
            text     = perf and "性能模式: 特效全开 · 165Hz" or "省电模式: 特效关闭 · 60Hz",
            duration = 2500,
            color    = perf and "rgb(a6e3a1)" or "rgb(f9e2af)",
        })
    end
end

-- 切换 ppd 档位并立即应用视效
local function powerMode(perf, notify)
    if perf then
        hl.exec_cmd("powerprofilesctl set performance || powerprofilesctl set balanced")
    else
        hl.exec_cmd("powerprofilesctl set power-saver")
    end
    applyVisuals(perf, notify)
end

-- 轮询 1: EPP 档位状态收敛
local function syncVisuals()
    local f = io.open("/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference", "r")
    if not f then return end
    local epp = f:read("*l")
    f:close()
    local perf = (epp ~= "power")
    if perf ~= lastPerf then applyVisuals(perf, lastPerf ~= nil) end
end

-- 轮询 2: AC 插拔自动切档
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

-- ── 电池电量梯度防护 ──
local BAT_WARN      = 15      -- 低电提醒
local BAT_SUSPEND   = 10      -- 挂起待休眠
local BAT_HIBERNATE = 5       -- 紧急落盘休眠

local SUSPEND_CMD   = "systemctl suspend-then-hibernate || systemctl suspend"
local HIBERNATE_CMD = "systemctl hibernate || systemctl suspend-then-hibernate || systemctl suspend"

local BAT_CANDIDATES = {
    "/sys/class/power_supply/BAT0",
    "/sys/class/power_supply/BAT1",
    "/sys/class/power_supply/BAT2",
    "/sys/class/power_supply/BAT",
}

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

local batWarned, batActed = false, false

local function checkBattery(ac)
    local cap, status = readBattery()
    if cap == nil then return end

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

    -- ≤5%: 紧急落盘休眠
    if cap <= BAT_HIBERNATE and not batActed then
        batActed, batWarned = true, true
        hl.notification.create({
            text     = string.format("电量仅 %d%%, 即将休眠落盘", cap),
            duration = 5000,
            color    = "rgb(f38ba8)",
        })
        hl.exec_cmd(HIBERNATE_CMD)
        return
    end

    -- ≤10%: 挂起待休眠
    if cap <= BAT_SUSPEND and not batActed then
        batActed, batWarned = true, true
        hl.notification.create({
            text     = string.format("电量 %d%%, 即将挂起待休眠", cap),
            duration = 5000,
            color    = "rgb(fab387)",
        })
        hl.exec_cmd(SUSPEND_CMD)
        return
    end

    -- ≤15%: 低电提醒
    if cap <= BAT_WARN and not batWarned then
        batWarned = true
        hl.notification.create({
            text     = string.format("电量偏低 %d%%, 请及时充电", cap),
            duration = 5000,
            color    = "rgb(f9e2af)",
        })
    end
end

local function pollPower()
    local ac = acOnline()
    -- 首拍静默对齐
    if ac ~= nil and lastAc == nil then
        lastAc = ac
        powerMode(ac, false)
    else
        syncVisuals()
        if ac ~= nil and ac ~= lastAc then
            lastAc = ac
            powerMode(ac)
        end
    end
    checkBattery(ac)
end

-- 每 3 秒执行一次周期巡检
hl.timer(pollPower, { timeout = 3000, type = "repeat" })

return {
    powerMode = powerMode,
    dimRules  = dimRules,
}
