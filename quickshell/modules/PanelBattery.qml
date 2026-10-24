// 面板 · 电池：只读显示百分比与充电状态。数据来自 UPower.displayDevice，属性绑定事件驱动。
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs

Column {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property int percent: Math.round((root.device?.percentage ?? 0) * 100)
    readonly property int state: root.device?.state ?? UPowerDeviceState.Unknown

    readonly property string stateText: {
        switch (root.state) {
        case UPowerDeviceState.Charging: return "充电中";
        case UPowerDeviceState.Discharging: return "放电中";
        case UPowerDeviceState.FullyCharged: return "已充满";
        case UPowerDeviceState.PendingCharge: return "等待充电";
        case UPowerDeviceState.PendingDischarge: return "等待放电";
        case UPowerDeviceState.Empty: return "已耗尽";
        default: return "未知";
        }
    }

    spacing: 8

    Row {
        width: parent.width

        Text {
            id: batLabel
            text: "电池"
            color: Theme.battery
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
        }

        Item {
            width: parent.width - batLabel.implicitWidth - batState.implicitWidth
            height: 1
        }

        Text {
            id: batState
            text: root.percent + "%  ·  " + root.stateText
            color: Theme.battery
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
        }
    }

    // 只读进度条
    Rectangle {
        width: parent.width
        height: 6
        radius: 3
        color: Qt.rgba(1, 1, 1, 0.12)

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.percent / 100))
            height: parent.height
            radius: 3
            color: root.state === UPowerDeviceState.Charging ? Theme.charging
                 : root.state === UPowerDeviceState.FullyCharged ? Theme.full
                 : Theme.battery
        }
    }
}
