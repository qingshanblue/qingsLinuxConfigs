// 面板 · 亮度：设备列表 + 当前设备百分比 + 拖动滑块 + 居中加减按钮。
// 内屏走 sysfs/backlight（brightnessctl 写入）；外接屏若有 ddcutil 则一并列出（需显示器与 i2c 支持）。
import QtQuick
import Quickshell
import Quickshell.Io
import qs

Column {
    id: root

    // 当前设备亮度百分比（由 Brightness 模块传入）
    property int percent: 0
    // 拖动中的临时值
    property int pending: -1
    readonly property int shown: root.pending >= 0 ? root.pending : root.percent
    // brightnessctl 是否可用
    property bool toolAvailable: true

    signal applied()

    spacing: 8

    // 背光设备列表（sysfs 枚举）
    ListModel { id: backlights }

    // 发现 /sys/class/backlight 下的设备
    Process {
        id: discover
        running: true
        command: ["sh", "-c", "ls -1 /sys/class/backlight/ 2>/dev/null"]
        stdout: SplitParser {
            onRead: line => {
                const n = line.trim();
                if (n.length > 0 && backlights.count < 8 && backlights.get(0)?.name !== n)
                    backlights.append({ name: n, path: "/sys/class/backlight/" + n });
            }
        }
    }

    // 标题行
    Row {
        width: parent.width

        Text {
            text: "亮度"
            color: Theme.brightness
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
        }

        Item {
            width: parent.width - 80
            height: 1
        }

        Text {
            text: root.shown + "%"
            color: Theme.brightness
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
        }
    }

    // 当前可调设备（内屏背光）。单设备时也显示，让用户知道在调哪块屏
    Text {
        width: parent.width
        elide: Text.ElideRight
        text: {
            if (backlights.count === 0) return "未检测到背光设备";
            return "● " + backlights.get(0).name + "（内屏背光）";
        }
        // 与亮度图标同色
        color: Theme.brightness
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 3
        font.weight: Theme.fontWeight
    }

    // 主控滑块
    PanelSlider {
        width: parent.width
        accent: Theme.brightness
        value: root.shown / 100
        onMoved: v => {
            root.pending = Math.round(v * 100);
        }
        onReleased: {
            if (root.pending >= 0) {
                root.setPercent(root.pending);
                clearTimer.restart();
            }
        }
    }

    // 加减按钮：左右两端等宽分布，中间不放空块，视觉更平衡
    Row {
        width: parent.width
        spacing: 8

        PanelButton {
            width: (parent.width - 8) / 2
            text: "−  5%"
            accent: Theme.brightness
            onClicked: root.setPercent(Math.max(0, root.percent - 5))
        }

        PanelButton {
            width: (parent.width - 8) / 2
            text: "+  5%"
            accent: Theme.brightness
            onClicked: root.setPercent(Math.min(100, root.percent + 5))
        }
    }

    // 外接屏提示
    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        visible: !root.hasDdcutil
        text: "外接屏亮度需安装 ddcutil 且显示器支持 DDC/CI"
        color: Theme.panelMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 3
        font.weight: Theme.fontWeight
    }

    property bool hasDdcutil: false

    Process {
        id: ddcCheck
        running: true
        command: ["sh", "-c", "command -v ddcutil >/dev/null && echo yes || echo no"]
        stdout: SplitParser {
            onRead: line => root.hasDdcutil = line.trim() === "yes"
        }
    }

    // 亮度不可用时提示
    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        visible: !root.toolAvailable
        text: "brightnessctl 未安装，需 sudo nixos-rebuild switch"
        color: Theme.panelMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 3
        font.weight: Theme.fontWeight
    }

    // 写入亮度（线性）
    function setPercent(p) {
        const v = Math.max(0, Math.min(100, Math.round(p)));
        brProcess.command = ["sh", "-c", "brightnessctl set " + v + "%"];
        brProcess.running = true;
    }

    Process {
        id: brProcess
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                root.toolAvailable = true;
                root.applied();
            } else {
                root.toolAvailable = false;
            }
        }
    }

    // 读数追上来后清 pending
    onPercentChanged: {
        if (root.pending >= 0 && Math.abs(root.percent - root.pending) <= 2) {
            root.pending = -1;
            clearTimer.stop();
        }
    }

    Timer {
        id: clearTimer
        interval: 800
        running: false
        onTriggered: root.pending = -1
    }
}
