// 面板通用小按钮：圆角块，可指定文字与强调色。
import QtQuick
import qs

Rectangle {
    id: root

    property string text: ""
    property color accent: Theme.panelText
    property bool armed: true          // false 时半透明且不可点
    signal clicked()

    implicitWidth: Math.max(56, label.implicitWidth + 20)
    implicitHeight: 24
    radius: 7
    color: area.containsMouse && root.armed
        ? Qt.rgba(1, 1, 1, 0.16)
        : Qt.rgba(1, 1, 1, 0.07)
    opacity: root.armed ? 1 : 0.45

    Behavior on color { ColorAnimation { duration: 120 } }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.accent
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
        font.weight: Theme.fontWeight
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        enabled: root.armed
        onClicked: root.clicked()
    }
}
