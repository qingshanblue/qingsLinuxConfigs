-- 快捷键 · 窗口管理 (WINDOW MANAGEMENT)
-- 涵盖: 窗口状态、布局尺寸调整、窗口移动与跨工作区跳跃

local mainMod       = require("apps.defs").mainMod
local moveWindowNav = require("features.scratchpad").moveWindowNav

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. 窗口状态 (关闭 / 浮动 / 钉住 / 全屏 / 鼠标交互)
-- ═══════════════════════════════════════════════════════════════════════════

-- 关闭当前窗口
hl.bind(mainMod .. "+Q", hl.dsp.window.close())

-- 窗口浮动切换
hl.bind(mainMod .. "+F", hl.dsp.window.float({ action = "toggle" }))

-- 钉住浮动窗口 (固定在所有工作区可见)
hl.bind(mainMod .. "+CTRL+F", hl.dsp.window.pin({ action = "toggle" }))

-- 全屏切换 (Scrolling 布局下可平滑滚走，滚回仍保持全屏)
hl.bind(mainMod .. "+SHIFT+F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- 鼠标拖动与尺寸调节
hl.bind(mainMod .. "+mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. "+mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. 布局调整 (Scrolling 胶带列与视野)
-- ═══════════════════════════════════════════════════════════════════════════

-- 列宽循环: 0.33 / 0.5 / 0.667 / 1.0 (高频)
hl.bind(mainMod .. "+R", hl.dsp.layout("colresize +conf"))

-- 单列 ↔ 并入右列 (纵向并排 ↔ 横向并排)
hl.bind(mainMod .. "+SHIFT+R", hl.dsp.layout("consume_or_expel next"))

-- 锁定 / 解锁视野自动跟随滚动
hl.bind(mainMod .. "+CTRL+R", hl.dsp.layout("inhibit_scroll"))

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. 窗口移动与搬移 (SUPER + SHIFT)
-- ═══════════════════════════════════════════════════════════════════════════

-- 数字键 1-0: 搬移窗口至工作区 1-10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. "+SHIFT+" .. key, hl.dsp.window.move({ workspace = i }))
end

-- 与相邻列交换位置
hl.bind(mainMod .. "+SHIFT+A", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. "+SHIFT+D", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. "+SHIFT+mouse:276", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. "+SHIFT+mouse:275", hl.dsp.layout("swapcol r"))

-- 搬移窗口至上一个 / 下一个工作区 (特殊区开启时在特殊区之间流转)
hl.bind(mainMod .. "+SHIFT+W", function() moveWindowNav(-1) end)
hl.bind(mainMod .. "+SHIFT+S", function() moveWindowNav(1) end)
hl.bind(mainMod .. "+SHIFT+mouse_up", function() moveWindowNav(-1) end)
hl.bind(mainMod .. "+SHIFT+mouse_down", function() moveWindowNav(1) end)

-- 方向键: 跨列 / 跨行搬移窗口
hl.bind(mainMod .. "+SHIFT+left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. "+SHIFT+right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. "+SHIFT+up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. "+SHIFT+down", hl.dsp.window.move({ direction = "d" }))

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. 历史回跳 (窗口往返切换)
-- ═══════════════════════════════════════════════════════════════════════════

-- Super+Tab: 跳到"最近聚焦的非特殊工作区窗口" (特殊区不计入; A/B 交替往返)
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
