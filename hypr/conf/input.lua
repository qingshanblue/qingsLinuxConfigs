-- 键鼠 / 触控板 (INPUT)

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
