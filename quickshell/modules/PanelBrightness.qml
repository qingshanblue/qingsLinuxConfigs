// 面板 · 亮度：可拖动滑块 + 加减按钮，写入调用 brightnessctl（线性 5% 步进）。
// 拖动过程中只更新本地显示（pending），松手才执行一次 brightnessctl，
// 避免每帧都起进程导致卡顿。写入成功后发 applied()，由外层立即刷新读数。
import QtQuick
import Quickshell.Io
import qs

Column {
    id: root

    // 亮度写入成功后发出，供外部立即刷新读数
    signal applied()

    // 当前亮度百分比（0-100），由外部传入
    property int percent: 0
    // brightnessctl 是否可用（调用失败后置 false）
    property bool toolAvailable: true
    // 拖动中的临时值；-1 表示未在拖动
    property int pending: -1
    // 实际显示的值：拖动中优先用 pending，响应更跟手
    readonly property int shown: root.pending >= 0 ? root.pending : root.percent

    spacing: 10

    // 标题行：名称 + 百分比
    Row {
        width: parent.width

        Text {
            id: brLabel
            text: "亮度"
            color: Theme.brightness
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
        }

        Item {
            width: parent.width - brLabel.implicitWidth - brValue.implicitWidth
            height: 1
        }

        Text {
            id: brValue
            text: root.shown + "%"
            color: Theme.brightness
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
        }
    }

    // 可拖动滑块
    PanelSlider {
        width: parent.width
        accent: Theme.brightness
        value: root.shown / 100
        onMoved: v => {
            root.pending = Math.round(v * 100);
            // 拖动中按节流真正写硬件，让实际亮度跟随滑块，而不是等松手
            if (!applyThrottle.running) {
                root.setPercent(root.pending);
                applyThrottle.start();
            }
        }
        onReleased: {
            applyThrottle.stop();
            if (root.pending >= 0) {
                root.setPercent(root.pending);
                // 先不清 pending：等真实读数追上来再清，否则会瞬间回跳到旧值
                clearTimer.restart();
            }
        }
    }

    // 加减按钮：线性 5% 步进（不用 -e4 指数模式，否则 5% 实际会跳约 18 个单位）
    Row {
        width: parent.width
        spacing: 10

        Rectangle {
            width: 64
            height: 26
            radius: 8
            color: brDown.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.07)

            Text {
                anchors.centerIn: parent
                text: "−  5%"
                color: Theme.brightness
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.weight: Theme.fontWeight
            }

            MouseArea {
                id: brDown
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.setPercent(Math.max(0, root.percent - 5))
            }
        }

        Rectangle {
            width: 64
            height: 26
            radius: 8
            color: brUp.containsMouse ? Qt.rgba(1, 1, 1, 0.14) : Qt.rgba(1, 1, 1, 0.07)

            Text {
                anchors.centerIn: parent
                text: "+  5%"
                color: Theme.brightness
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 1
                font.weight: Theme.fontWeight
            }

            MouseArea {
                id: brUp
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.setPercent(Math.min(100, root.percent + 5))
            }
        }
    }

    // brightnessctl 不可用时的提示（仅在失败后出现，不弹窗）
    Text {
        width: parent.width
        visible: !root.toolAvailable
        wrapMode: Text.WordWrap
        text: "brightnessctl 未安装，需 sudo nixos-rebuild switch"
        color: Theme.wsEmptyText
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
        font.weight: Theme.fontWeight
    }

    // 读数追上来后清掉 pending；兜底 1.5 秒后也清（写入失败时不至于卡住显示）
    onPercentChanged: {
        if (root.pending >= 0 && Math.abs(root.percent - root.pending) <= 2) {
            root.pending = -1;
            clearTimer.stop();
        }
    }

    // 拖动节流：一次写入后 120ms 内不再写，避免每帧起进程
    Timer {
        id: applyThrottle
        interval: 120
        running: false
        repeat: false
    }

    Timer {
        id: clearTimer
        interval: 1500
        running: false
        onTriggered: root.pending = -1
    }

    // 以百分比写入亮度
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
                root.applied();   // 立即重读，不等 5 秒轮询
            } else {
                root.toolAvailable = false;
            }
        }
    }
}
