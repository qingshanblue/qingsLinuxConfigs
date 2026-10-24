// 面板开关：纯 QML 绘制的胶囊开关。状态由外部绑定 checked；点击只发出 toggled(新值)，
// 不在内部改写 checked，避免打断外部绑定（服务状态变化时仍能自动刷新）。
import QtQuick
import qs

Item {
    id: root

    property bool checked: false
    property bool enabledState: true      // 不可用时（如硬件关闭）置 false
    signal toggled(bool value)

    implicitWidth: 40
    implicitHeight: 20
    opacity: root.enabledState ? 1 : 0.4

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Theme.network : Qt.rgba(1, 1, 1, 0.12)
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    Rectangle {
        id: knob
        width: root.height - 4
        height: width
        radius: height / 2
        y: 2
        x: root.checked ? root.width - width - 2 : 2
        color: "#eefff1"
        Behavior on x {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        enabled: root.enabledState
        onClicked: root.toggled(!root.checked)
    }
}
