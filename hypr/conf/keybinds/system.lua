-- 快捷键 · 应用启动 / 系统 / 多媒体与截图

local terminal = require("conf.programs").terminal
local fileManager = require("conf.programs").fileManager
local menu = require("conf.programs").menu
local browser = require("conf.programs").browser
local coder = require("conf.programs").coder
local mainMod = require("conf.programs").mainMod
local powerMode = require("conf.power").powerMode

-- ═══ 应用启动(常用软件单键 + walker)═══

-- 应用启动器:Super+Space 归 fcitx 切输入法、Ctrl+Space 打游戏会用,故用 Alt+Space
hl.bind("ALT+SPACE", hl.dsp.exec_cmd(menu))
-- 终端
hl.bind(mainMod .. "+T", hl.dsp.exec_cmd(terminal))
-- 浏览器
hl.bind(mainMod .. "+B", hl.dsp.exec_cmd(browser))
-- 剪贴板历史
hl.bind(mainMod .. "+V", hl.dsp.exec_cmd("walker -m clipboard"))
-- 文件管理器
hl.bind(mainMod .. "+E", hl.dsp.exec_cmd(fileManager))
-- VS Code
hl.bind(mainMod .. "+H", hl.dsp.exec_cmd(coder))
-- 任务管理器
hl.bind(mainMod .. "+ESCAPE", hl.dsp.exec_cmd("missioncenter"))

-- ═══ 系统(电源 / 锁屏 / 关闭)═══

-- 进省电:动画/blur/阴影关,不透明,60Hz,CPU→power-saver
hl.bind(mainMod .. "+CTRL+P", function() powerMode(false) end)
-- 回性能:特效全开,165Hz,CPU→balanced
hl.bind(mainMod .. "+CTRL+SHIFT+P", function() powerMode(true) end)

-- 一键开关窗口透明(SUPER+O):在「性能透明值」与「全部不透明」之间切换
-- 注意:省电模式下本身就全不透明;此开关只改 decoration 透明度,不动动画/阴影/刷新率
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
-- 退出(有 hyprshutdown 就用它,否则退回 hyprctl exit)
hl.bind(mainMod .. "+M",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- ═══ 多媒体与功能键(笔记本)═══

-- 音量 +(上限 100%)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
-- 音量 -
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
-- 输出静音开关
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true })
-- 麦克风静音开关
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true })
-- 亮度 +
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
-- 亮度 -
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })
-- 上一曲
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
-- 下一曲(需 playerctl)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
-- 播放/暂停
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- 自定义播放控制
-- 上一曲
hl.bind(mainMod .. "+page_up", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
-- 下一曲
hl.bind(mainMod .. "+page_down", hl.dsp.exec_cmd("playerctl next"), { locked = true })
-- 播放/暂停
hl.bind(mainMod .. "+delete", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- ═══ 截图与录制 ═══

-- 区域截图(框选时画面冻结)
hl.bind(mainMod .. "+CTRL+A", hl.dsp.exec_cmd("hyprshot -m region -z -o $HOME/Pictures/screenshot"))
-- 窗口截图
hl.bind(mainMod .. "+CTRL+S", hl.dsp.exec_cmd("hyprshot -m window -o $HOME/Pictures/screenshot"))
-- 区域截图并钉住(swayimg 悬浮,文件存 /tmp 重启自清;看完 Super+Q 关)
-- 注:hyprshot 1.3 的截图在后台子进程完成,主进程退出码恒为 1(它自带的 -- command 也只支持无参命令),
-- 故不依赖退出码:打时间戳 → 截图 → 轮询 pin.png 是否更新(30s 超时,Esc 取消则不弹窗)
hl.bind(mainMod .. "+CTRL+D", hl.dsp.exec_cmd(
    "touch /tmp/.pin_stamp; hyprshot -m region -s -z -o /tmp -f pin.png; i=0; until [ /tmp/pin.png -nt /tmp/.pin_stamp ] || [ $i -ge 100 ]; do sleep 0.3; i=$((i+1)); done; j=0; while [ -n \"$(pgrep -x grim)\" ] && [ $j -lt 50 ]; do sleep 0.2; j=$((j+1)); done; if [ /tmp/pin.png -nt /tmp/.pin_stamp ]; then eval set -- $(hyprctl monitors | awk '$1==\"Monitor\"{mon=$2} $1~/^[0-9]+x[0-9]+@/{match($1,/x/);x1=RSTART;match($1,/@/);x2=RSTART;pw=substr($1,1,x1-1);ph=substr($1,x1+1,x2-x1-1)} /scale:/{sc=$2} /transform:/{tr=$2} $1==\"focused:\"&&$2==\"yes\"{if(tr%2==1){print int(ph/sc),int(pw/sc),int(sc*1000)}else{print int(pw/sc),int(ph/sc),int(sc*1000)}}'); MW=$1; MH=$2; SCM=$3; set -- $(od -An -j 16 -N 8 -t u1 /tmp/pin.png); W=$(($1*16777216+$2*65536+$3*256+$4)); H=$(($5*16777216+$6*65536+$7*256+$8)); W=$(($W*1000/SCM)); H=$(($H*1000/SCM)); S=1000; [ $(($MW*800)) -lt $(($W*1000)) ] && S=$(($MW*800/$W)); [ $(($MH*800)) -lt $(($H*1000)) ] && [ $(($MH*800/$H)) -lt $S ] && S=$(($MH*800/$H)); swayimg -a pinshot -S $(($W*S/1000)),$(($H*S/1000)) /tmp/pin.png; fi"
))
-- OBS:暂停/恢复录制
hl.bind(mainMod .. "+F10", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" }))
-- OBS:开始录制
hl.bind(mainMod .. "+F11", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" }))
-- OBS:停止录制
hl.bind(mainMod .. "+F12", hl.dsp.pass({ window = "class:^(com.obsproject.Studio)$" }))
