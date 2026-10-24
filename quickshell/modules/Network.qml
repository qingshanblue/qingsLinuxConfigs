// 网络：Wi-Fi 图标 + 信号百分比数字，不显示 SSID（用户明确要求）。
// 没有 Wi-Fi 设备时整个模块隐藏。数据来自 Quickshell.Networking，事件驱动。
import QtQuick
import Quickshell.Networking
import qs

Row {
    id: root

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property bool connected: root.wifi?.connected ?? false

    // 信号强度挂在"已连接的接入点"(WifiNetwork)上,而不是设备本身(设备无此属性,会恒为 0)
    readonly property var activeNet: root.wifi?.networks?.values?.find(n => n.connected) ?? null

    // signalStrength 部分版本给 0-1,部分给 0-100,统一换算到 0-1
    readonly property real rawStrength: root.activeNet?.signalStrength ?? 0
    readonly property real strength: root.rawStrength > 1 ? root.rawStrength / 100 : root.rawStrength

    readonly property string icon: {
        if (!root.connected) return "󰤭";           // 未连接（wifi-off，F092D）
        if (root.strength < 0.25) return "󰤟";     // wifi-strength-1
        if (root.strength < 0.50) return "󰤢";     // wifi-strength-2
        if (root.strength < 0.75) return "󰤥";     // wifi-strength-3
        return "󰤨";                               // wifi-strength-4
    }

    visible: root.wifi !== null

    // 点击唤出的控制面板类型（见 ControlPanel.qml）
    readonly property string panelKind: "network"
    spacing: 4

    Text {
        text: root.icon
        color: root.connected ? Theme.network : Theme.wsEmptyText
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
    }

    // 信号百分比数字(已连接时显示,断开时隐藏)
    Text {
        visible: root.connected
        text: Math.round(root.strength * 100) + "%"
        color: Theme.network
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
    }
}
