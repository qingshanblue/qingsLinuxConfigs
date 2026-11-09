-- 快捷键 · 工作区管理 (WORKSPACE MANAGEMENT)
-- 涵盖: 常规工作区导航、特殊工作区 (Scratchpad) 呼出、多显示器工作区调度

local mainMod            = require("apps.defs").mainMod
local navWorkspace       = require("features.scratchpad").navWorkspace
local toggleSpecialLayer = require("features.scratchpad").toggleSpecialLayer
local toggleSpecialNamed = require("features.scratchpad").toggleSpecialNamed

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. 常规工作区与滚动胶带导航 (WASD + 方向键 + 滚轮)
-- ═══════════════════════════════════════════════════════════════════════════

-- 数字键 1-0: 切换工作区 1-10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. "+" .. key, hl.dsp.focus({ workspace = i }))
end

-- 胶带水平滚动 (左右移动视野)
hl.bind(mainMod .. "+A", hl.dsp.layout("move -col"))
hl.bind(mainMod .. "+D", hl.dsp.layout("move +col"))
hl.bind(mainMod .. "+mouse:276", hl.dsp.layout("move -col"))  -- 侧键前进
hl.bind(mainMod .. "+mouse:275", hl.dsp.layout("move +col"))  -- 侧键后退

-- 垂直切换工作区 (W/S、滚轮; 特殊区开着时在特殊区之间流转)
hl.bind(mainMod .. "+W", function() navWorkspace(-1) end)
hl.bind(mainMod .. "+S", function() navWorkspace(1) end)
hl.bind(mainMod .. "+mouse_up", function() navWorkspace(-1) end)
hl.bind(mainMod .. "+mouse_down", function() navWorkspace(1) end)

-- 方向键: 聚焦相邻窗口
hl.bind(mainMod .. "+left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. "+right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. "+up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. "+down", hl.dsp.focus({ direction = "down" }))

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. 特殊工作区 (Scratchpad: magic / maho / mofa)
-- ═══════════════════════════════════════════════════════════════════════════

-- 总开关: 开着则直接收起当前，未开则呼出最近使用的特殊区
hl.bind(mainMod .. "+GRAVE", function() toggleSpecialLayer() end)
hl.bind(mainMod .. "+mouse:274", function() toggleSpecialLayer() end) -- Super + 中键 / 三指点

-- magic (Z): 开合 / 送入
hl.bind(mainMod .. "+Z", function() toggleSpecialNamed("magic") end)
hl.bind(mainMod .. "+SHIFT+Z", hl.dsp.window.move({ workspace = "special:magic" }))

-- maho (X): 开合 / 送入
hl.bind(mainMod .. "+X", function() toggleSpecialNamed("maho") end)
hl.bind(mainMod .. "+SHIFT+X", hl.dsp.window.move({ workspace = "special:maho" }))

-- mofa (C): 开合 / 送入
hl.bind(mainMod .. "+C", function() toggleSpecialNamed("mofa") end)
hl.bind(mainMod .. "+SHIFT+C", hl.dsp.window.move({ workspace = "special:mofa" }))

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. 多显示器工作区调度 (单屏时自动 safe no-op)
-- ═══════════════════════════════════════════════════════════════════════════

-- 返回按序排列的下一台显示器名称
local function nextMonitor()
    local cur, names = hl.get_active_monitor(), {}
    for _, m in ipairs(hl.get_monitors()) do names[#names + 1] = m.name end
    for i, n in ipairs(names) do
        if n == cur.name then return names[i % #names + 1] end
    end
end

-- 当前工作区整体搬到下一块屏 (焦点跟随过去)
hl.bind(mainMod .. "+G", function()
    local o = nextMonitor()
    if o then hl.dispatch(hl.dsp.workspace.move({ monitor = o })) end
end)

-- 当前屏与下一块屏的工作区整体对调 (焦点不动，内容互换)
hl.bind(mainMod .. "+SHIFT+G", function()
    local o = nextMonitor()
    if o then hl.dispatch(hl.dsp.workspace.swap_monitors({ monitor1 = hl.get_active_monitor().name, monitor2 = o })) end
end)

-- Super+Ctrl+1~0: 将指定编号工作区循环迁移到下一块屏
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
