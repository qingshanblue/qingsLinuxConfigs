// 工作区按钮：显示所有普通工作区（id > 0，忽略 special）。
// 激活态（白底黑字）只标记"本屏当前工作区"，因此两块屏幕各有一个高亮，但列表内容相同。
// 有窗口的数字亮，空的暗。点击切换工作区（切到本屏）。
// 在整排上滚轮可切换到上一个/下一个工作区。
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs

Item {
    id: root

    property string monitorName: ""

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    // 本屏当前工作区 id（白色高亮只认这个）。
    // 走 Monitors 单例：它监听 Hyprland 事件并主动刷新，避开 lastIpcObject 不通知的问题。
    readonly property int activeOnThisScreen: Monitors.activeByMonitor[root.monitorName] ?? -1

    // 所有普通工作区，按 id 排序（跨屏共享同一列表）
    readonly property var wsList: Hyprland.workspaces.values
        .filter(ws => ws.id > 0)
        .sort((a, b) => a.id - b.id)

    Row {
        id: row
        spacing: 4

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
                readonly property bool isActive: chip.ws.id === root.activeOnThisScreen
                color: chip.isActive ? Theme.wsActiveBg : "transparent"

                Text {
                    id: label
                    anchors.centerIn: parent
                    text: chip.ws.id
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.weight: Theme.fontWeight
                    // 非激活工作区统一配色，避免 4~10 与 1~3 看起来不一致
                    color: chip.isActive ? Theme.wsActiveText : Theme.wsOccupiedText
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: chip.ws.activate()
                    // 鼠标停在数字上时，滚轮也要能切换工作区
                    onWheel: wheel => root.scrollWorkspaces(wheel.angleDelta.y)
                }
            }
        }
    }

    // 滚动切换工作区（供按钮与空白处共用）
    function scrollWorkspaces(deltaY) {
        const ids = root.wsList.map(w => w.id);
        if (ids.length === 0) return;
        const step = deltaY > 0 ? -1 : 1;
        const curIdx = ids.indexOf(Hyprland.focusedWorkspace?.id ?? -1);
        let nextIdx;
        if (curIdx < 0) {
            nextIdx = step > 0 ? 0 : ids.length - 1;
        } else {
            nextIdx = Math.max(0, Math.min(ids.length - 1, curIdx + step));
        }
        if (nextIdx !== curIdx) {
            // 用 hyprctl 直接派发：本机 Hyprland 走 Lua 派发，且 workspace 需为字符串
            wsProc.command = ["hyprctl", "dispatch", 'hl.dsp.focus({workspace="' + ids[nextIdx] + '"})'];
            wsProc.running = true;
        }
    }

    Process {
        id: wsProc
    }

    // 空白处滚轮（按钮之间的间隙）
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => root.scrollWorkspaces(wheel.angleDelta.y)
    }
}
