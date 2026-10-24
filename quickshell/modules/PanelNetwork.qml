// 面板 · 网络：Wi-Fi 开关 + 当前连接的 SSID 与信号百分比（只读，不做连接列表）。
// 数据来自 Quickshell.Networking；信号强度挂在已连接的接入点(WifiNetwork)上，不在设备上。
import QtQuick
import Quickshell.Networking
import qs

Column {
    id: root

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var activeNet: root.wifi?.networks?.values?.find(n => n.connected) ?? null

    // 信号强度部分版本给 0-1，部分给 0-100，统一换算到 0-1（与 modules/Network.qml 一致）
    readonly property real rawStrength: root.activeNet?.signalStrength ?? 0
    readonly property real strength: root.rawStrength > 1 ? root.rawStrength / 100 : root.rawStrength

    spacing: 8

    Row {
        width: parent.width

        Text {
            id: wifiLabel
            text: "Wi-Fi"
            color: Theme.network
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            width: parent.width - wifiLabel.implicitWidth - wifiToggle.width
            height: 1
        }

        PanelToggle {
            id: wifiToggle
            anchors.verticalCenter: parent.verticalCenter
            checked: Networking.wifiEnabled
            // 没有 Wi-Fi 设备或硬件开关关闭时不可操作
            enabledState: root.wifi !== null && Networking.wifiHardwareEnabled
            onToggled: v => {
                Networking.wifiEnabled = v;
            }
        }
    }

    // 连接状态（只读）
    Text {
        width: parent.width
        elide: Text.ElideRight
        text: {
            if (root.wifi === null) return "无 Wi-Fi 设备";
            if (!Networking.wifiEnabled) return "Wi-Fi 已关闭";
            if (root.activeNet === null) return "未连接";
            return root.activeNet.name + "  ·  " + Math.round(root.strength * 100) + "%";
        }
        color: root.activeNet !== null ? Theme.windowTitle : Theme.panelMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
    }
}
