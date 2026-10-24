// 魔法棒按钮（special:magic）。本阶段只做按钮与视觉，不执行任何 hyprctl dispatch。
import QtQuick
import qs

Text {
    id: btn

    text: "󰁨"   // md-auto_fix (F0068)，与 waybar 的 custom/scratchpad 一致
    color: Theme.magic
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        // TODO(第二阶段): 左键切换 special:magic 特殊工作区。本阶段保持空实现。
        onClicked: {}
    }
}
