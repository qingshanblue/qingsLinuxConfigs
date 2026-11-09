-- ═══════════════════════════════════════════════════════════════════════════
--  qings 的 Hyprland 配置 (Lua / Hyprland 0.55+) · 主入口文件
--  结构清晰分层: core(核心系统) / apps(应用与规则) / features(特性逻辑) / bindings(交互绑定)
-- ═══════════════════════════════════════════════════════════════════════════

-- 1. 核心系统环境与基础设置 (改动频率低)
require("core.env")          -- 环境变量、XWayland 缩放与光标
require("core.monitors")     -- 显示器输出模式、分辨率与缩放
require("core.look")         -- 外观主题、Catppuccin 渐变边框、阴影、动画与滚动布局
require("core.input")        -- 键鼠行为、触控板基础手势参数
require("core.startup")      -- 自启服务与常驻守护 (walker, sunshine, polkit, hyprlock 等)

-- 2. 动态特性与增强逻辑 (带 timer、电源联动、多工作区上下文)
require("features.power")    -- EPP 电源模式自动切档与低电梯级安全防护

-- 3. 窗口行为与规则
require("apps.rules")        -- 窗口规则、特殊区半透明联动、各类应用弹窗浮动

-- 4. 交互输入绑定 (最常查看与修改)
require("bindings.window")     -- 窗口状态、Scrolling 胶带列宽调整、搬移与历史跳回
require("bindings.workspace")  -- 工作区导航、特殊工作区 (Scratchpad) 呼出、多屏调度
require("bindings.system")     -- 快捷应用启动、系统电源/锁屏、多媒体、截图与录制
require("bindings.gestures")   -- 专为滚动胶带调优的 2/3/4 指触控板手势

-- 5. DMS 集成配置 (外部工具自动生成，末尾加载)
require("dms.outputs")
