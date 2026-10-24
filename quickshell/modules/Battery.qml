// 电池：显示百分比。充电时用插头图标（沿用 waybar 的 format-charging），未充电按电量分五档。
// 数据来自 UPower.displayDevice，属性变化事件驱动。
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import qs

Row {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property int percent: Math.round((root.device?.percentage ?? 0) * 100)
    readonly property bool charging: root.device?.state === UPowerDeviceState.Charging
    readonly property bool fullyCharged: root.device?.state === UPowerDeviceState.FullyCharged

    // 电量五档：0-19 空 ... 80-100 满（F244 空 -> F240 满，与 waybar 一致）
    readonly property string icon: {
        if (root.charging) return "\uF1E6";   // fa-plug（waybar format-charging）
        // 由空到满：F244 -> F240（与 waybar 一致）
        const levels = ["\uF244", "\uF243", "\uF242", "\uF241", "\uF240"];
        return levels[Math.min(4, Math.floor(root.percent / 20))];
    }

    readonly property color iconColor: {
        if (root.charging) return Theme.charging;
        if (root.fullyCharged) return Theme.full;
        return Theme.battery;
    }

    spacing: 4

    // 点击唤出的控制面板类型（见 ControlPanel.qml）
    readonly property string panelKind: "battery"

    Text {
        text: root.icon
        color: root.iconColor
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
    }

    Text {
        text: root.percent + "%"
        color: root.iconColor
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
    }
}
