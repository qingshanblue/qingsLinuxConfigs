// 面板 · 通知中心：勿扰开关 + 按应用分组的历史（可折叠）+ 清空全部。
// 数据来自 Notifs.history（NotificationServer.trackedNotifications），事件驱动。
import QtQuick
import qs

Column {
    id: root

    readonly property var items: Notifs.history

    // 折叠状态：appName -> bool（true 表示已折叠）
    property var collapsed: ({})

    // 按应用分组：{ app, entries[] }，组顺序按该组最新一条的先后（history 已是最新在前）
    readonly property var groups: {
        const map = {};
        const order = [];
        for (let i = 0; i < root.items.length; i++) {
            const n = root.items[i];
            const app = (n.appName && n.appName.length > 0) ? n.appName : "系统";
            if (!map[app]) {
                map[app] = [];
                order.push(app);
            }
            map[app].push(n);
        }
        return order.map(a => ({ app: a, entries: map[a] }));
    }

    function toggle(app) {
        const c = Object.assign({}, root.collapsed);
        c[app] = !c[app];
        root.collapsed = c;
    }

    function isCollapsed(app) {
        return root.collapsed[app] === true;
    }

    spacing: 8

    // 标题行
    Row {
        width: parent.width

        Text {
            id: notifyTitle
            text: "通知"
            color: Theme.notifyIdle
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            width: parent.width - notifyTitle.implicitWidth - (clearBtn.visible ? clearBtn.implicitWidth : 0)
            height: 1
        }

        Text {
            id: clearBtn
            visible: root.items.length > 0
            text: "清空全部"
            color: Theme.windowTitle
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Notifs.clearAll()
            }
        }
    }

    // 勿扰开关
    Row {
        width: parent.width

        Text {
            id: dndLabel
            text: "勿扰"
            color: Theme.windowTitle
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            width: parent.width - dndLabel.implicitWidth - dndToggle.width
            height: 1
        }

        PanelToggle {
            id: dndToggle
            anchors.verticalCenter: parent.verticalCenter
            checked: Notifs.dnd
            onToggled: v => Notifs.dnd = v
        }
    }

    // 空态
    Text {
        width: parent.width
        visible: root.groups.length === 0
        text: "暂无通知"
        color: Theme.panelMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
        font.weight: Theme.fontWeight
    }

    // 分组列表（可滚动）
    Flickable {
        id: flick
        width: parent.width
        height: Math.min(contentHeight, 340)
        contentHeight: groupCol.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: groupCol
            width: flick.width
            spacing: 10

            Repeater {
                model: root.groups

                delegate: Column {
                    id: grp
                    required property var modelData
                    width: groupCol.width
                    spacing: 4

                    // 分组头：整行可点，右侧显示折叠箭头
                    Rectangle {
                        width: parent.width
                        height: 26
                        radius: 6
                        color: headArea.containsMouse ? Qt.rgba(1, 1, 1, 0.10) : "transparent"

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6
                            spacing: 6

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: (root.isCollapsed(grp.modelData.app) ? "󰅂" : "󰅁")
                                color: Theme.notifyIdle
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 2
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: grp.modelData.app
                                color: Theme.notifyIdle
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 1
                                font.weight: Theme.fontWeight
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "(" + grp.modelData.entries.length + ")"
                                color: Theme.panelMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 3
                            }

                            Item {
                                width: 4
                                height: 1
                            }

                            // 关闭此应用（点击不冒泡到折叠）
                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: "全部关闭"
                                color: Theme.panelMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 3

                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -3
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        for (let i = 0; i < grp.modelData.entries.length; i++)
                                            Notifs.dismiss(grp.modelData.entries[i]);
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: headArea
                            anchors.fill: parent
                            hoverEnabled: true
                            // 让「全部关闭」的 MouseArea 优先接收到点击
                            propagateComposedEvents: true
                            onClicked: root.toggle(grp.modelData.app)
                        }
                    }

                    // 分组内容（折叠时隐藏）
                    Column {
                        width: parent.width
                        spacing: 8
                        visible: !root.isCollapsed(grp.modelData.app)

                        Repeater {
                            model: grp.modelData.entries

                            delegate: Column {
                                id: entry
                                required property var modelData
                                width: parent.width
                                spacing: 2

                                Text {
                                    width: parent.width
                                    visible: text !== ""
                                    wrapMode: Text.WordWrap
                                    text: entry.modelData.summary
                                    textFormat: Text.PlainText
                                    color: Theme.clockText
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize
                                    font.weight: Theme.fontWeight
                                }

                                Text {
                                    width: parent.width
                                    visible: text !== ""
                                    wrapMode: Text.WordWrap
                                    maximumLineCount: 3
                                    elide: Text.ElideRight
                                    text: entry.modelData.body
                                    textFormat: Text.PlainText
                                    color: Theme.windowTitle
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize - 1
                                    font.weight: Theme.fontWeight
                                }

                                // 单条关闭
                                Text {
                                    text: "关闭"
                                    color: Theme.panelMuted
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontSize - 3
                                    font.weight: Theme.fontWeight

                                    MouseArea {
                                        anchors.fill: parent
                                        anchors.margins: -3
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Notifs.dismiss(entry.modelData)
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width
                        height: 1
                        color: Theme.panelDivider
                    }
                }
            }
        }
    }
}
