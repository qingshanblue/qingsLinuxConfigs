// 面板 · 音量：滑块（0–100%）+ 静音开关。
// 数据来自 Pipewire 默认输出，属性绑定事件驱动。PwObjectTracker 用于保证读写的 sink 已就绪。
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs

Column {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool muted: root.sink?.audio?.muted ?? false
    readonly property real volume: root.sink?.audio?.volume ?? 0
    readonly property int percent: Math.round(root.volume * 100)

    spacing: 8

    PwObjectTracker {
        objects: [root.sink]
    }

    Text {
        text: "音量"
        color: Theme.audio
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
    }

    // 滑块行：滑块 + 百分比
    Row {
        width: parent.width
        spacing: Theme.spacing

        PanelSlider {
            id: slider
            width: parent.width - pct.width - Theme.spacing
            anchors.verticalCenter: parent.verticalCenter
            value: root.volume
            // 滑块范围 0–1（即 0–100%）；Pipewire 可超过 1（软件放大），此处不允许超过
            onMoved: v => {
                if (root.sink?.audio) root.sink.audio.volume = v;
            }
        }

        Text {
            id: pct
            text: root.percent + "%"
            color: Theme.audio
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
        }
    }

    // 静音开关行
    Row {
        width: parent.width

        Text {
            id: muteLabel
            text: "静音"
            color: Theme.windowTitle
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            width: parent.width - muteLabel.implicitWidth - muteToggle.width
            height: 1
        }

        PanelToggle {
            id: muteToggle
            anchors.verticalCenter: parent.verticalCenter
            checked: root.muted
            enabledState: !!root.sink
            onToggled: v => {
                if (root.sink?.audio) root.sink.audio.muted = v;
            }
        }
    }
}
