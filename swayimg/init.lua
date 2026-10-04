-- swayimg 全局配置
-- 载入/切换图片时隐藏文字信息层(文件名/分辨率等);需要查看时按 t 临时显示
swayimg.text.visible = false
swayimg.viewer.on_image_change(function() swayimg.text.visible = false end)
swayimg.gallery.on_image_change(function() swayimg.text.visible = false end)
