// 面板 · 蓝牙：开关 + 已连接设备名列表（只读）。
// 数据来自 Quickshell.Bluetooth，属性与设备连接状态都是事件驱动绑定，无轮询。
import QtQuick
import Quickshell.Bluetooth
import qs

Column {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    // 依赖设备对象的 connected 属性绑定：设备连接/断开时自动重算
    readonly property var connectedDevices: Bluetooth.devices.values.filter(d => d.connected)

    spacing: 8

    Row {
        width: parent.width

        Text {
            id: btLabel
            text: "蓝牙"
            color: Theme.audio
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            width: parent.width - btLabel.implicitWidth - btToggle.width
            height: 1
        }

        PanelToggle {
            id: btToggle
            anchors.verticalCenter: parent.verticalCenter
            checked: root.adapter?.enabled ?? false
            enabledState: root.adapter !== null
            onToggled: v => {
                if (root.adapter) root.adapter.enabled = v;
            }
        }
    }

    // 已连接设备列表（只读）
    Text {
        visible: root.connectedDevices.length === 0
        text: root.adapter === null ? "无蓝牙适配器" : (root.adapter.enabled ? "无已连接设备" : "蓝牙已关闭")
        color: Theme.panelMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
    }

    Repeater {
        model: root.connectedDevices

        delegate: Text {
            required property var modelData

            width: root.width
            elide: Text.ElideRight
            text: "\uF293  " + modelData.name   // 蓝牙图标（fa-bluetooth）+ 设备名
            color: Theme.windowTitle
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
        }
    }
}
