-- 快捷键 · 窗口:状态 / 布局 / 搬移 / 回跳

local mainMod = require("conf.programs").mainMod
local moveWindowNav = require("conf.specials").moveWindowNav

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
