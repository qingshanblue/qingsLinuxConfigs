// 面板滑块：纯 QML 绘制，值域 0–1。
// 拖动/点击时发出 moved(新值)；外部 value 变化只刷新显示，不回写，避免与服务状态互相打架。
import QtQuick
import qs

Item {
    id: root

    // 滑块颜色，默认音量蓝；亮度面板会传 Theme.brightness
    property color accent: Theme.audio
    property real value: 0
    readonly property real clamped: Math.max(0, Math.min(1, root.value))
    signal moved(real value)
    signal released()

    implicitWidth: 200
    implicitHeight: 16

    function setFromX(x) {
        root.moved(Math.max(0, Math.min(1, x / root.width)));
    }

    // 轨道
    Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        height: 6
        radius: 3
        color: Qt.rgba(1, 1, 1, 0.12)

        // 已填充部分
        Rectangle {
            width: track.width * root.clamped
            height: parent.height
            radius: 3
            color: root.accent
        }
    }

    // 拇指
    Rectangle {
        width: 12
        height: 12
        radius: 6
        color: root.accent
        anchors.verticalCenter: parent.verticalCenter
        x: track.width * root.clamped - width / 2
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPressed: mouse => root.setFromX(mouse.x)
        onPositionChanged: mouse => {
            if (pressed) root.setFromX(mouse.x);
        }
        onReleased: root.released()
    }
}
