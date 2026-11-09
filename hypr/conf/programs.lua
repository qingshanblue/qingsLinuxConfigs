-- 程序变量 (MY PROGRAMS):供快捷键 / 窗口规则引用

-- 供下面 hl.bind / hl.window_rule 引用的程序变量

-- 终端
local terminal    = "kitty"
-- 文件管理器
local fileManager = "nemo"
-- 应用启动器 / 搜索
local menu        = "walker"
-- 浏览器
local browser     = "google-chrome-stable"
-- 图片查看器
local imageViewr  = "swayimg"
-- 视频播放器
local videoViewr  = "Celluloid"
-- 通知守护
local notifier    = "swaync"
-- 代码编辑器
local coder       = "code"
-- 压缩包管理器
local archiver    = "ark"
-- 状态栏(现由 dms.service 自启;此行只供手动跑,启动前先 systemctl --user stop dms)
local statusBar   = "dms run --session"
-- 壁纸
local wallpaper   = "hyprpaper"

-- 主修饰键(快捷键与手势共用)
local mainMod = "SUPER"

return {
    terminal = terminal,
    fileManager = fileManager,
    menu = menu,
    browser = browser,
    imageViewr = imageViewr,
    videoViewr = videoViewr,
    notifier = notifier,
    coder = coder,
    archiver = archiver,
    statusBar = statusBar,
    wallpaper = wallpaper,
    mainMod = mainMod,
}
