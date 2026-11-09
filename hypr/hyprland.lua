-- ═══════════════════════════════════════════════════════════════════════════
--  qings 的 Hyprland 配置(Lua/Hyprland 0.55+)· 入口文件
--  约定:注释统一写在对应代码的「上方」;快捷键主修饰键 mainMod = SUPER
--
--  模块结构(hypr/conf/ 下,按 require 顺序加载;顺序即原配置段落顺序):
--    conf/programs.lua      程序变量(终端/浏览器/...,及 mainMod)
--    conf/monitors.lua      显示器
--    conf/autostart.lua     开机自启
--    conf/env.lua           环境变量
--    conf/look.lua          外观 / 动效
--    conf/misc.lua          杂项 + 权限
--    conf/input.lua         键鼠 / 触控板
--    conf/power.lua         省电 / 性能模式(被快捷键、窗口规则引用)
--    conf/specials.lua      特殊工作区辅助逻辑(被快捷键、手势引用)
--    conf/keybinds/         快捷键
--      window.lua           窗口状态 / 布局 / 搬移 / 回跳
--      workspace.lua        工作区导航 / 特殊工作区
--      monitor.lua          多屏工作区调度
--      apps.lua             应用启动
--      system.lua           电源 / 锁屏 / 退出 / 透明度
--      media.lua            多媒体功能键 / 截图录制
--    conf/gestures.lua      触控板手势
--    conf/rules.lua         窗口 / 工作区规则
--    dms/                   DMS 自动生成的配置(末尾加载,暂保留原行为)
-- ═══════════════════════════════════════════════════════════════════════════

require("conf.programs")
require("conf.monitors")
require("conf.autostart")
require("conf.env")
require("conf.look")
require("conf.misc")
require("conf.input")
require("conf.power")
require("conf.keybinds.window")
require("conf.keybinds.workspace")
require("conf.keybinds.monitor")
require("conf.keybinds.apps")
require("conf.keybinds.system")
require("conf.keybinds.media")
require("conf.gestures")
require("conf.rules")

-- DMS Include Configs(保持最后加载)
require("dms.outputs")
