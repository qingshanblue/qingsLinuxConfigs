// 工作区按钮：只显示本屏（monitorName）的普通工作区（id > 0），忽略 special 工作区（id < 0）。
// 激活态白底黑字；有窗口的数字亮，空的暗。点击切换工作区。
import QtQuick
import Quickshell.Hyprland
import qs

Row {
    id: root

    property string monitorName: ""

    spacing: 4

    // 过滤并按 id 排序；Hyprland.workspaces.values 变化时自动重算
    readonly property var wsList: Hyprland.workspaces.values
        .filter(ws => ws.id > 0 && ws.monitor?.name === root.monitorName)
        .sort((a, b) => a.id - b.id)

    Repeater {
        model: root.wsList

        delegate: Rectangle {
            id: chip

            required property var modelData
            readonly property var ws: modelData
            readonly property bool occupied: (ws.lastIpcObject?.windows ?? 0) > 0

            implicitWidth: label.implicitWidth + 12
            implicitHeight: Theme.pillHeight - 8
            radius: height / 2
            color: ws.active ? Theme.wsActiveBg : "transparent"

            Text {
                id: label
                anchors.centerIn: parent
                text: chip.ws.id
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: Theme.fontWeight
                color: chip.ws.active ? Theme.wsActiveText
                     : chip.occupied ? Theme.wsOccupiedText
                     : Theme.wsEmptyText
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: chip.ws.activate()
            }
        }
    }
}
