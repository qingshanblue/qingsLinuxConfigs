-- 杂项系统行为与键鼠/触控板配置 (INPUT & MISC)
-- 参考: https://wiki.hypr.land/Configuring/Variables/#input

hl.config({
    misc = {
        -- 禁用自带默认动漫壁纸与 logo
        force_default_wallpaper = -1,
        disable_hyprland_logo   = true,
        -- vfr(变帧率) 默认即为 true; 常驻动画关闭后 VFR 能充分发挥省电效用
    },
})

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        follow_mouse = 1,
        -- -1.0 ~ 1.0, 0 表示不做修改
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
            scroll_factor  = 0.33,
            -- 按指头数点击: 1 指=左键, 2 指=右键, 3 指=中键 (替代右下角软按钮区)
            clickfinger_behavior = true,
        },
    },
})
