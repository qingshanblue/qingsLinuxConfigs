// 时钟：只显示 HH:mm（24 小时制）。悬停时在药丸下方弹出完整日期提示。
// 更新：按分钟对齐的单次 Timer，每分钟触发一次，不做高频轮询。
import QtQuick
import Quickshell
import qs

Item {
    id: root

    property date now: new Date()
    readonly property var weekNames: ["日", "一", "二", "三", "四", "五", "六"]

    implicitWidth: label.implicitWidth
    implicitHeight: label.implicitHeight

    // 距离下一个整分钟的毫秒数
    function msToNextMinute() {
        const d = new Date();
        return 60000 - (d.getSeconds() * 1000 + d.getMilliseconds());
    }

    function fullDate(d) {
        return d.getFullYear() + "年" + (d.getMonth() + 1) + "月" + d.getDate()
            + "日 星期" + weekNames[d.getDay()];
    }

    Timer {
        id: minuteTimer
        running: true
        repeat: false
        interval: root.msToNextMinute()
        onTriggered: {
            root.now = new Date();
            interval = root.msToNextMinute();
            restart();
        }
    }

    Text {
        id: label
        text: Qt.formatTime(root.now, "HH:mm")
        color: Theme.clockText
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
    }

    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    // 悬停提示：锚定在时钟下方
    PopupWindow {
        id: tip
        visible: hover.containsMouse
        color: "transparent"
        implicitWidth: tipText.implicitWidth + 16
        implicitHeight: tipText.implicitHeight + 8

        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom

        Rectangle {
            anchors.fill: parent
            radius: 6
            color: Theme.pillBg
            border.color: Theme.pillBorder
            border.width: 1

            Text {
                id: tipText
                anchors.centerIn: parent
                text: root.fullDate(root.now)
                color: Theme.clockText
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: Theme.fontWeight
            }
        }
    }
}
