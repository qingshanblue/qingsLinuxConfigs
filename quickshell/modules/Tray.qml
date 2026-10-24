// 托盘抽屉：默认折叠，只显示一个把手（chevron-right，与 waybar 一致）。
// 点击把手展开/收起；展开时 SystemTray.items 的图标依次从把手右侧滑出。
// 左键 activate，右键发信号交给自绘菜单（TrayMenu），其余按钮 secondaryActivate。
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import qs

Row {
    id: root

    // 右键请求菜单：携带托盘项与用于锚定的图标对象
    signal menuRequested(var item, var anchorItem)

    // 所属的 PanelWindow
    property var bar
    property bool expanded: false

    height: Theme.trayIconSize
    spacing: 0

    // 把手（常驻）。展开后旋转 180 度，指向收起方向。
    Item {
        id: handle
        width: handleGlyph.implicitWidth
        height: parent.height

        Text {
            id: handleGlyph
            anchors.centerIn: parent
            text: "󰅂"   // md-chevron-right (F0142)
            color: Theme.tray
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
            rotation: root.expanded ? 180 : 0
            Behavior on rotation {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.expanded = !root.expanded
        }
    }

    // 抽屉容器：宽度从 0 动画到内容宽度，超出部分裁剪
    Item {
        id: drawer
        height: parent.height
        clip: true
        width: root.expanded ? trayRow.implicitWidth + trayRow.x : 0
        Behavior on width {
            NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }

        Row {
            id: trayRow
            x: Theme.spacing / 2   // 与把手保持间距
            height: parent.height
            spacing: 6

            Repeater {
                model: SystemTray.items

                // 外层 Item 负责固定占位与图标回退；图标加载失败时显示首字母
                delegate: Item {
                    id: traySlot

                    required property var modelData

                    implicitWidth: Theme.trayIconSize
                    implicitHeight: Theme.trayIconSize

                    IconImage {
                        id: trayIcon
                        anchors.fill: parent
                        implicitSize: Theme.trayIconSize
                        source: traySlot.modelData.icon ?? ""
                        // 加载成功才显示，否则让位给回退文字
                        visible: status === Image.Ready
                    }

                    // 回退：取标题首字母；没有标题则用通用图标字形
                    Text {
                        anchors.centerIn: parent
                        visible: trayIcon.status !== Image.Ready
                        text: {
                            const t = traySlot.modelData.title ?? "";
                            return t.length > 0 ? t.charAt(0).toUpperCase() : "󰀻";
                        }
                        color: Theme.tray
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                        font.weight: Theme.fontWeight
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        onClicked: mouse => {
                            if (mouse.button === Qt.LeftButton) {
                                traySlot.modelData.activate();
                            } else if (mouse.button === Qt.RightButton && traySlot.modelData.hasMenu) {
                                // 不用 display()（平台菜单位置会跑偏），交给自绘菜单
                                root.menuRequested(traySlot.modelData, traySlot);
                            } else {
                                traySlot.modelData.secondaryActivate();
                            }
                        }
                    }
                }
            }
        }
    }
}
