-- 快捷键 · 系统:电源 / 锁屏 / 退出 / 透明度

local mainMod = require("conf.programs").mainMod
local powerMode = require("conf.power").powerMode

-- ═══ 系统(电源 / 锁屏 / 关闭)═══

-- 进省电:动画/blur/阴影关,不透明,60Hz,CPU→power-saver
hl.bind(mainMod .. "+CTRL+P", function() powerMode(false) end)
-- 回性能:特效全开,165Hz,CPU→balanced
hl.bind(mainMod .. "+CTRL+SHIFT+P", function() powerMode(true) end)

-- 一键开关窗口透明(SUPER+O):在「性能透明值」与「全部不透明」之间切换
-- 注意:省电模式下本身就全不透明;此开关只改 decoration 透明度,不动动画/阴影/刷新率
local transparencyOn = true
hl.bind(mainMod .. "+O", function()
    transparencyOn = not transparencyOn
    hl.config({
        decoration = {
            active_opacity   = transparencyOn and 0.96 or 1,
            inactive_opacity = transparencyOn and 0.84 or 1,
        },
    })
end)
-- 锁屏
hl.bind(mainMod .. "+L", hl.dsp.exec_cmd("hyprlock"))
-- 退出(有 hyprshutdown 就用它,否则退回 hyprctl exit)
hl.bind(mainMod .. "+M",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
