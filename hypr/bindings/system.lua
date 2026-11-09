-- 快捷键 · 系统控制、启动与多媒体 (SYSTEM, LAUNCHERS & MEDIA)
-- 涵盖: 快捷应用启动、系统电源与锁屏、全局透明度切换、笔记本多媒体按键、截图与 OBS 录制

local apps      = require("apps.defs")
local mainMod   = apps.mainMod
local powerMode = require("features.power").powerMode

-- ═══════════════════════════════════════════════════════════════════════════
-- 1. 应用与工具启动
-- ═══════════════════════════════════════════════════════════════════════════

-- 应用启动器 (Alt+Space: 避免与 Fcitx5 输入法及游戏键位冲突)
hl.bind("ALT+SPACE", hl.dsp.exec_cmd(apps.menu))

-- 终端
hl.bind(mainMod .. "+T", hl.dsp.exec_cmd(apps.terminal))

-- 浏览器
hl.bind(mainMod .. "+B", hl.dsp.exec_cmd(apps.browser))

-- 剪贴板历史
hl.bind(mainMod .. "+V", hl.dsp.exec_cmd("walker -m clipboard"))

-- 文件管理器
hl.bind(mainMod .. "+E", hl.dsp.exec_cmd(apps.fileManager))

-- VS Code 编辑器
hl.bind(mainMod .. "+H", hl.dsp.exec_cmd(apps.coder))

-- 系统任务管理器
hl.bind(mainMod .. "+ESCAPE", hl.dsp.exec_cmd("missioncenter"))

-- ═══════════════════════════════════════════════════════════════════════════
-- 2. 系统、电源与锁屏
-- ═══════════════════════════════════════════════════════════════════════════

-- 切换至省电模式: 关动画/阴影/模糊、窗口全不透明、60Hz、CPU power-saver
hl.bind(mainMod .. "+CTRL+P", function() powerMode(false) end)

-- 切换至性能模式: 特效全开、165Hz、CPU performance/balanced
hl.bind(mainMod .. "+CTRL+SHIFT+P", function() powerMode(true) end)

-- 快捷开关全局窗口半透明 (Super+O)
local transparencyOn = true
hl.bind(mainMod .. "+O", function()
    transparencyOn = not transparencyOn
    hl.config({
        decoration = {
            active_opacity   = transparencyOn and 0.96 or 1,
            inactive_opacity = transparencyOn and 0.84 or 1,
        },
    })
end)

-- 锁屏
hl.bind(mainMod .. "+L", hl.dsp.exec_cmd("hyprlock"))

-- 会话退出 / 关机菜单
hl.bind(mainMod .. "+M",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- ═══════════════════════════════════════════════════════════════════════════
-- 3. 笔记本多媒体与硬件按键
-- ═══════════════════════════════════════════════════════════════════════════

-- 音量加减与静音
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true })

-- 屏幕亮度加减
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

-- 媒体播放控制 (硬件键)
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

-- 媒体播放控制 (键盘辅助键: PageUp / PageDown / Delete)
hl.bind(mainMod .. "+page_up", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind(mainMod .. "+page_down", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind(mainMod .. "+delete", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })

-- ═══════════════════════════════════════════════════════════════════════════
-- 4. 截图与 OBS 录制
-- ═══════════════════════════════════════════════════════════════════════════

-- 区域截图 (画面冻结)
hl.bind(mainMod .. "+CTRL+A", hl.dsp.exec_cmd("hyprshot -m region -z -o $HOME/Pictures/screenshot"))

-- 活动窗口截图
hl.bind(mainMod .. "+CTRL+S", hl.dsp.exec_cmd("hyprshot -m window -o $HOME/Pictures/screenshot"))

-- 区域截图并置顶钉住 (swayimg 居中悬浮, 文件存入 /tmp)
hl.bind(mainMod .. "+CTRL+D", hl.dsp.exec_cmd(
    "touch /tmp/.pin_stamp; hyprshot -m region -s -z -o /tmp -f pin.png; i=0; until [ /tmp/pin.png -nt /tmp/.pin_stamp ] || [ $i -ge 100 ]; do sleep 0.3; i=$((i+1)); done; j=0; while [ -n \"$(pgrep -x grim)\" ] && [ $j -lt 50 ]; do sleep 0.2; j=$((j+1)); done; if [ /tmp/pin.png -nt /tmp/.pin_stamp ]; then eval set -- $(hyprctl monitors | awk '$1==\"Monitor\"{mon=$2} $1~/^[0-9]+x[0-9]+@/{match($1,/x/);x1=RSTART;match($1,/@/);x2=RSTART;pw=substr($1,1,x1-1);ph=substr($1,x1+1,x2-x1-1)} /scale:/{sc=$2} /transform:/{tr=$2} $1==\"focused:\"&&$2==\"yes\"{if(tr%2==1){print int(ph/sc),int(pw/sc),int(sc*1000)}else{print int(pw/sc),int(ph/sc),int(sc*1000)}}'); MW=$1; MH=$2; SCM=$3; set -- $(od -An -j 16 -N 8 -t u1 /tmp/pin.png); W=$(($1*16777216+$2*65536+$3*256+$4)); H=$(($5*16777216+$6*65536+$7*256+$8)); W=$(($W*1000/SCM)); H=$(($H*1000/SCM)); S=1000; [ $(($MW*800)) -lt $(($W*1000)) ] && S=$(($MW*800/$W)); [ $(($MH*800)) -lt $(($H*1000)) ] && [ $(($MH*800/$H)) -lt $S ] && S=$(($MH*800/$H)); swayimg -a pinshot -S $(($W*S/1000)),$(($H*S/1000)) /tmp/pin.png; fi"
))

-- OBS 快捷操作 (直通信号至 OBS 窗口)
hl.bind(mainMod .. "+F10", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" })) -- 暂停/恢复录制
hl.bind(mainMod .. "+F11", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" })) -- 开始录制
hl.bind(mainMod .. "+F12", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" })) -- 停止录制
