-- 触控板手势 (GESTURES)

local S = require("conf.specials")
local mainMod = require("conf.programs").mainMod
local navWorkspace = require("conf.specials").navWorkspace
local moveWindowNav = require("conf.specials").moveWindowNav
local getActiveSpecialName = require("conf.specials").getActiveSpecialName

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
            hl.dispatch(hl.dsp.focus({ workspace = "special:" .. S.last() }))
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
