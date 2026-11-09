-- 快捷键 · 应用启动

local terminal = require("conf.programs").terminal
local fileManager = require("conf.programs").fileManager
local menu = require("conf.programs").menu
local browser = require("conf.programs").browser
local coder = require("conf.programs").coder
local mainMod = require("conf.programs").mainMod

-- ═══ 应用启动(常用软件单键 + walker)═══

-- 应用启动器:Super+Space 归 fcitx 切输入法、Ctrl+Space 打游戏会用,故用 Alt+Space
hl.bind("ALT+SPACE", hl.dsp.exec_cmd(menu))
-- 终端
hl.bind(mainMod .. "+T", hl.dsp.exec_cmd(terminal))
-- 浏览器
hl.bind(mainMod .. "+B", hl.dsp.exec_cmd(browser))
-- 剪贴板历史
hl.bind(mainMod .. "+V", hl.dsp.exec_cmd("walker -m clipboard"))
-- 文件管理器
hl.bind(mainMod .. "+E", hl.dsp.exec_cmd(fileManager))
-- VS Code
hl.bind(mainMod .. "+H", hl.dsp.exec_cmd(coder))
-- 任务管理器
hl.bind(mainMod .. "+ESCAPE", hl.dsp.exec_cmd("missioncenter"))
