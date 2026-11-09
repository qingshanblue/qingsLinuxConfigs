-- 默认应用与全局常量定义 (APPS / CONSTANTS)
-- 供快捷键绑定、窗口规则以及启动项等模块引用

-- 核心修饰键 (快捷键与触控板手势共用)
local mainMod     = "SUPER"

-- 默认应用
local terminal    = "kitty"                    -- 终端
local fileManager = "nemo"                     -- 文件管理器
local menu        = "walker"                   -- 应用启动器 / 搜索
local browser     = "google-chrome-stable"     -- 浏览器
local coder       = "code"                     -- 代码编辑器
local imageViewr  = "swayimg"                  -- 图片查看器
local videoViewr  = "Celluloid"                -- 视频播放器
local archiver    = "ark"                      -- 压缩包管理器
local notifier    = "swaync"                   -- 通知守护
local wallpaper   = "hyprpaper"                -- 壁纸守护
local statusBar   = "dms run --session"        -- 状态栏 (由 dms.service 托管，手动启动前需停用 systemctl --user stop dms)

return {
    mainMod     = mainMod,
    terminal    = terminal,
    fileManager = fileManager,
    menu        = menu,
    browser     = browser,
    coder       = coder,
    imageViewr  = imageViewr,
    videoViewr  = videoViewr,
    archiver    = archiver,
    notifier    = notifier,
    wallpaper   = wallpaper,
    statusBar   = statusBar,
}
