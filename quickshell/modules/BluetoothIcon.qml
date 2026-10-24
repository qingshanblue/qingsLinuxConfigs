// 蓝牙图标：未启用 󰂲（灰）、已连接设备 󰂱、可用但无连接 󰂯。字形与 waybar 的 bluetooth 模块一致。
// 点击唤出蓝牙面板（panelKind = "bluetooth"）。没有蓝牙适配器时整个模块隐藏。
import QtQuick
import Quickshell.Bluetooth
import qs

Text {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool enabledState: root.adapter?.enabled ?? false
    readonly property int connectedCount: Bluetooth.devices.values.filter(d => d.connected).length

    // 点击唤出的控制面板类型（见 ControlPanel.qml）
    readonly property string panelKind: "bluetooth"

    readonly property string icon: {
        if (!root.enabledState) return "󰂲";       // 关闭
        if (root.connectedCount > 0) return "󰂱";  // 已连接
        return "󰂯";                               // 开启、无连接
    }

    visible: root.adapter !== null
    text: root.icon
    // 开启时用 #a4e4fe；关闭时灰色（waybar 的 bluetooth.off 配色）
    color: root.enabledState ? Theme.audio : Theme.panelMuted
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight
}
