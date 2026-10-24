// 亮度：读取 /sys/class/backlight/nvidia_0 的 brightness。
// 亮度变化没有 DBus/PipeWire 那样的事件源，但内核会在写亮度时发 udev change 事件，
// 所以用 udevadm monitor 订阅 backlight 子系统 —— 与音量一样是事件驱动，改完立即更新。
// 图标沿用 waybar 的 backlight 图标，按 低 / 中 / 高 三档选取。
import QtQuick
import Quickshell.Io
import qs

Row {
    id: root

    property real current: 0
    property real maximum: 1
    readonly property int percent: root.maximum > 0 ? Math.round(root.current / root.maximum * 100) : 0

    // 点击唤出的控制面板类型（见 ControlPanel.qml）
    readonly property string panelKind: "brightness"

    readonly property string icon: {
        if (root.percent < 34) return "\uE38D";   // 低亮度（waybar backlight 第一档）
        if (root.percent < 67) return "\uE3CE";   // 中亮度
        return "\uE39B";                          // 高亮度
    }

    spacing: 4

    FileView {
        id: brightnessFile
        path: "/sys/class/backlight/nvidia_0/brightness"
        blockLoading: true
        onLoaded: root.current = Number(brightnessFile.text()) || 0
    }

    FileView {
        id: maxBrightnessFile
        path: "/sys/class/backlight/nvidia_0/max_brightness"
        blockLoading: true
        onLoaded: root.maximum = Number(maxBrightnessFile.text()) || 1
    }

    // 事件驱动：订阅 backlight 子系统的 udev 事件，每次亮度变化立即重读。
    // KERNEL 与 UDEV 各发一次事件，用短去抖合并，避免重复读取。
    Process {
        id: udevMonitor
        running: true
        // -q 静默其它输出；--property 便于按行解析
        command: ["udevadm", "monitor", "--subsystem-match=backlight", "--property"]
        stdout: SplitParser {
            onRead: line => {
                // 事件起始行形如 KERNEL[123.456] change ... 或 UDEV  [...]
                if (line.indexOf("change") < 0 && line.indexOf("KERNEL") < 0 && line.indexOf("UDEV") < 0)
                    return;
                debounce.restart();
            }
        }
        // 进程意外退出时延迟重启，避免拖垮系统
        onExited: restartTimer.start()
    }

    Timer {
        id: debounce
        interval: 60
        running: false
        onTriggered: root.refresh()
    }

    // 兜底：udev 监听失效时仍能靠低频轮询更新（5 秒一次，代价可忽略）
    Timer {
        id: restartTimer
        interval: 5000
        running: false
        onTriggered: udevMonitor.running = true
    }

    Timer {
        id: fallbackPoll
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    // 立即重读一次亮度（面板里的 +/- 点击后由外部调用，避免等到下一次轮询）
    function refresh() {
        brightnessFile.reload();   // max_brightness 是常量，不必每次都读
    }

    Text {
        text: root.icon
        color: Theme.brightness
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
    }

    Text {
        text: root.percent + "%"
        color: Theme.brightness
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
    }
}
