// 面板 · 通知中心：勿扰开关 + 历史列表（最新在上，每条可关闭）+ 清空全部。
// 数据来自 Notifs.history（即 NotificationServer.trackedNotifications），列表高度有上限，超出可滚动。
import QtQuick
import qs

Column {
    id: root

    readonly property var items: Notifs.history

    spacing: 8

    // 标题行：通知 + 清空全部（有历史时显示）
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

    // 勿扰开关（与右键切换勿扰同一状态）
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
            onToggled: v => {
                Notifs.dnd = v;
            }
        }
    }

    Text {
        visible: root.items.length === 0
        text: "暂无通知"
        color: Theme.panelMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
    }

    // 历史列表：高度上限 360，超出滚动
    ListView {
        id: list
        width: parent.width
        visible: root.items.length > 0
        height: Math.min(contentHeight, 360)
        clip: true
        spacing: 10
        model: root.items

        delegate: Column {
            id: entry

            required property var modelData

            width: list.width
            spacing: 2

            Row {
                width: parent.width

                Text {
                    id: appText
                    width: parent.width - closeText.implicitWidth - 8
                    elide: Text.ElideRight
                    text: entry.modelData.appName || "通知"
                    textFormat: Text.PlainText
                    color: Theme.panelMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                    font.weight: Theme.fontWeight
                }

                Text {
                    id: closeText
                    text: "×"
                    color: Theme.windowTitle
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.weight: Theme.fontWeight

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Notifs.dismiss(entry.modelData)
                    }
                }
            }

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
        }
    }
}
