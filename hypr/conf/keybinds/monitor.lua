-- 快捷键 · 多屏工作区调度

local mainMod = require("conf.programs").mainMod

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
