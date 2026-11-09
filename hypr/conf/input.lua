-- 杂项 (MISC) / 权限 (PERMISSIONS) 与键鼠 (INPUT)

-- 参考:https://wiki.hypr.land/Configuring/Advanced-and-Cool/Permissions/
-- (当前未配置任何权限规则)

-- vfr(变帧率)默认即为 true,无需显式声明;此前 borderangle 常驻动画已关,VFR 现在能真正生效
hl.config({
    misc = {
        -- 设为 0 或 1 可禁用自带动漫壁纸
        force_default_wallpaper = -1,
        -- 关掉随机 hyprland logo / 动漫背景
        disable_hyprland_logo = true,
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
        -- -1.0 ~ 1.0,0 表示不做修改
        sensitivity = 0,
        touchpad = {
            natural_scroll = true,
            scroll_factor  = 0.33,
            -- 按指头数点击:1 指=左键,2 指=右键,3 指=中键(替代右下角软按钮区)
            clickfinger_behavior = true
        },
    },
})
