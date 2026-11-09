-- 触控板手势 (TOUCHPAD GESTURES)
-- 专为 Scrolling 胶带布局调优的直觉手势

local scratchpad           = require("features.scratchpad")
local mainMod              = require("apps.defs").mainMod
local navWorkspace         = scratchpad.navWorkspace
local moveWindowNav        = scratchpad.moveWindowNav
local getActiveSpecialName = scratchpad.getActiveSpecialName

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. 缩放与视野手势
-- ═══════════════════════════════════════════════════════════════════════════

-- Super + 双指捏合: 调整当前窗口大小 (右下=放大 / 左上=缩小; 普通双指留给应用原生缩放)
hl.gesture({
    fingers   = 2,
    direction = "pinch",
    mods      = mainMod,
    action    = "resize",
})

-- 三指捏合: 跟手放大镜，锚定当前光标位置 (再捏一次复原)
hl.gesture({
    fingers    = 3,
    direction  = "pinch",
    action     = "cursor_zoom",
    zoom_level = 1,
    mode       = "live",
})

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. 胶带滚动与窗口移动
-- ═══════════════════════════════════════════════════════════════════════════

-- 三指横滑: 跟手左右滚动平铺胶带 (长行程平滑移动)
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "scroll_move",
})

-- Super + Shift + 三指横滑: 跟手平移当前窗口位置
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    mods      = mainMod .. "+SHIFT",
    action    = "move",
})

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. 工作区切换与特殊区手势
-- ═══════════════════════════════════════════════════════════════════════════

-- 三指竖滑: 切换工作区 (上滑=下一个, 下滑=上一个; 特殊区开着时在特殊区之间流转)
local gy3 = 0
hl.gesture({
    fingers   = 3,
    direction = "vertical",
    action    = {
        start  = function() gy3 = 0 end,
        update = function(e) gy3 = gy3 + e.delta.y end,
        finish = function()
            if gy3 < -40 then
                navWorkspace(1)
            elseif gy3 > 40 then
                navWorkspace(-1)
            end
        end,
    },
})

-- Super + Shift + 三指竖滑: 将当前窗口转移至相邻工作区 (人跟随过去)
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
                moveWindowNav(-1)
            elseif ws_dy > 40 then
                moveWindowNav(1)
            end
        end,
    },
})

-- 四指上滑: 呼出最近使用的特殊工作区 (Scratchpad)
hl.gesture({
    fingers   = 4,
    direction = "up",
    action    = function()
        if getActiveSpecialName() == nil then
            hl.dispatch(hl.dsp.focus({ workspace = "special:" .. scratchpad.last() }))
        end
    end,
})

-- 四指下滑: 快速收起当前激活的特殊工作区
hl.gesture({
    fingers   = 4,
    direction = "down",
    action    = function()
        local cur = getActiveSpecialName()
        if cur ~= nil then
            hl.dispatch(hl.dsp.workspace.toggle_special(cur))
        end
    end,
})
