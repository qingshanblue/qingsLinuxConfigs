-- 快捷键 · 工作区:导航 / 特殊工作区

local mainMod = require("conf.programs").mainMod
local navWorkspace = require("conf.specials").navWorkspace
local toggleSpecialLayer = require("conf.specials").toggleSpecialLayer
local toggleSpecialNamed = require("conf.specials").toggleSpecialNamed

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

-- ═══ 特殊工作区(scratchpad:magic / maho / mofa)═══

-- 层开关:开着则直接收起当前,没开则呼出最近使用的(不用先猜当前是哪个)
hl.bind(mainMod .. "+GRAVE", function() toggleSpecialLayer() end)
-- Super + 中键:同 Super+` 的层开关(触控板上即 Super+三指轻点,clickfinger 三指点击=中键)
hl.bind(mainMod .. "+mouse:274", function() toggleSpecialLayer() end)
-- magic(Z):开合
hl.bind(mainMod .. "+Z", function() toggleSpecialNamed("magic") end)
-- magic(Z):把窗口扔进去
hl.bind(mainMod .. "+SHIFT+Z", hl.dsp.window.move({ workspace = "special:magic" }))
-- maho(X):开合
hl.bind(mainMod .. "+X", function() toggleSpecialNamed("maho") end)
-- maho(X):把窗口扔进去
hl.bind(mainMod .. "+SHIFT+X", hl.dsp.window.move({ workspace = "special:maho" }))
-- mofa(C):开合
hl.bind(mainMod .. "+C", function() toggleSpecialNamed("mofa") end)
-- mofa(C):把窗口扔进去
hl.bind(mainMod .. "+SHIFT+C", hl.dsp.window.move({ workspace = "special:mofa" }))
