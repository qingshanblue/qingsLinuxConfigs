-- 显示器配置 (MONITORS)
-- 参考: https://wiki.hypr.land/Configuring/Basics/Monitors/

-- 内屏 eDP-1: 最高刷新率
-- 显式 1.6：Hyprland 的 "auto" 也会算出 1.6（物理 PPI≈188 → 默认 1.5，
-- 但 2560/1.5 不是整数，向上就近取到 1.6），显式写死可保证与各 X11 程序里写死的 1.6 一致。
hl.monitor({
    output   = "eDP-1",
    mode     = "highrr",
    position = "0x0",
    scale    = 1.6,
})

-- 备用内屏 eDP-2 (暂未启用)
-- hl.monitor({
--     output   = "eDP-2",
--     mode     = "highrr",
--     position = "auto",
--     scale    = "auto",
-- })

-- 竖屏外接屏 DP-1 (2560x1600@160Hz)
-- transform = 1 为 90° 旋转; 若画面上下颠倒改成 3
-- position 放在主屏左侧、底边对齐 (竖屏后高 2560, 上边界远高于主屏)
hl.monitor({
    output    = "DP-1",
    mode      = "highrr",
    transform = 1,
    position  = "-1600x-0",
    scale     = 1.6,
})

-- HDMI-A-1: 镜像内屏
hl.monitor({
    output   = "HDMI-A-1",
    mirror   = "eDP-1",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
