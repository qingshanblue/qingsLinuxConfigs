-- 杂项 (MISC) 与权限 (PERMISSIONS,当前未配置)

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
