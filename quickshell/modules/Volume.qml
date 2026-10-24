// 音量：图标随档位变化（静音或 0 用 󰝟，低 󰕿，中 󰖀，高 󰕾），文字显示百分比。
// 数据来自 Pipewire 默认输出设备，属性变化事件驱动，无轮询。
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs

Row {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool muted: root.sink?.audio?.muted ?? true
    readonly property real volume: root.sink?.audio?.volume ?? 0
    readonly property int percent: Math.round(root.volume * 100)

    // 点击唤出的控制面板类型（见 ControlPanel.qml）
    readonly property string panelKind: "volume"

    readonly property string icon: {
        if (root.muted || root.percent === 0) return "󰝟";
        if (root.percent < 33) return "󰕿";
        if (root.percent < 66) return "󰖀";
        return "󰕾";
    }

    spacing: 4

    // 读取 sink 的属性前必须用 PwObjectTracker 追踪它
    PwObjectTracker {
        objects: [root.sink]
    }

    Text {
        text: root.icon
        color: Theme.audio
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
    }

    Text {
        text: root.percent + "%"
        color: Theme.audio
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
    }
}
