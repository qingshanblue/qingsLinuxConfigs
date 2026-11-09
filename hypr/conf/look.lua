-- 外观 / 动效 (LOOK AND FEEL)

hl.config({
    general = {
        gaps_in  = 2,
        -- 外围留多点呼吸感,窗口像"悬浮卡片"
        gaps_out = { top = 3, bottom = 7, left = 7, right = 7 },
        -- 想让渐变更显眼可以试 3
        border_size = 3,
        col = {
            -- 常规工作区 = 紫→粉渐变(备选:黄 f9e2af / 琥珀 e5c890 / 暖白 f5e0dc)
            active_border = {
                colors = { "rgba(cba6f7ee)", "rgba(f5c2e7ee)" },
                angle  = 90
            },
            inactive_border = "rgba(45475a88)",
        },
        resize_on_border = false,
        allow_tearing    = false,
        -- 无限平铺;想回老手感改回 "dwindle"
        layout = "scrolling",
    },
    decoration = {
        rounding       = 14,
        rounding_power = 2,
        active_opacity = 0.96,
        -- 非活动窗口轻微压暗,聚焦更明确
        inactive_opacity = 0.84,
        shadow = {
            enabled = true,
            -- 更大更柔的散开,面板感更强
            range        = 28,
            render_power = 3,
            offset       = { 0, 6 },
            -- 带一点蓝调的黑,柔和底部投影
            color = 0x661a1a26,
        },
        blur = {
            enabled = true,
            -- 调小:只保留轻微虚化,不再是厚重的奶玻璃,文字更清晰
            size   = 3,
            passes = 1,
            -- 去掉偏色/提亮/噪点,保证前景可读
            vibrancy = 0.0,
            contrast   = 1.0,
            brightness = 1.0,
            noise      = 0.0,
        },
    },
    animations = { enabled = true },
})

-- 自定义曲线
-- snappy:窗口开合(想要更弹就换成 bouncy)
hl.curve("snappy", { type = "spring", mass = 1, stiffness = 230, dampening = 26 })
-- bouncy:更弹的弹簧
hl.curve("bouncy", { type = "spring", mass = 1, stiffness = 300, dampening = 22 })
-- easeOutQuint:标准缓出曲线
hl.curve("easeOutQuint", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1 } } })
-- easeOutExpo:更干脆的收尾,用于窗口关闭与特殊区
hl.curve("easeOutExpo", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
-- easeInOutCubic:两端都缓,用于工作区横向/纵向切换
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0 }, { 0.35, 1 } } })

-- 窗口开合更有生命感
hl.animation({ leaf = "windows", enabled = true, speed = 3.5, spring = "snappy" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, spring = "snappy", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.2, bezier = "easeOutExpo", style = "popin 92%" })
-- 卷轴(scrolling)布局中窗口横向滑动:与工作区切换同一节奏
hl.animation({ leaf = "windowsMove", enabled = true, speed = 12, bezier = "easeOutExpo" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.5, bezier = "easeOutQuint" })
hl.animation({ leaf = "layers", enabled = true, speed = 3, bezier = "easeOutQuint", style = "fade" })
-- 边框颜色过渡:快速跟随焦点变化
hl.animation({ leaf = "border", enabled = true, speed = 6, bezier = "easeOutQuint" })
-- 工作区切换:垂直滑动,两端缓动,配合三指上下滑的方向感
hl.animation({ leaf = "workspaces", enabled = true, speed = 12, bezier = "easeOutExpo", style = "slidevert" })
-- 特殊工作区从底部滑入
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3.5, bezier = "easeOutExpo", style = "slidevert" })
-- 渐变边框流动动画:loop 模式会持续重绘导致 VFR 完全失效(空闲时 GPU/CPU 也常驻工作),为续航关闭;想要流动效果改回 enabled = true
-- hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "linear", style = "loop" })

-- 参考:https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/
hl.config({ scrolling = { fullscreen_on_one_column = true } })
