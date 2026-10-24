// 通知按钮（右区最右侧）：左键唤出通知中心，右键切换勿扰。
// 图标与配色沿用 waybar 的 custom/notification：有未读 󰂚 红、无未读 󰂞 淡青、勿扰 󰂛 灰蓝。
import QtQuick
import qs

Text {
    id: root

    // 左键时发出，由 Bar.qml 调用控制面板
    signal activated()

    // 点击唤出的控制面板类型（见 ControlPanel.qml）
    readonly property string panelKind: "notify"

    readonly property string icon: Notifs.dnd ? "󰂛" : (Notifs.unread > 0 ? "󰂚" : "󰂞")
    readonly property color iconColor: Notifs.dnd ? Theme.notifyDnd
                                     : (Notifs.unread > 0 ? Theme.notifyUnread : Theme.notifyIdle)

    text: root.icon
    color: root.iconColor
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => {
            if (mouse.button === Qt.RightButton) Notifs.dnd = !Notifs.dnd;
            else root.activated();
        }
    }
}
