// 通知弹出卡片：屏幕右上角（药丸下方）堆叠显示，超时自动消失（Notifs.toastMs）。
// 点卡片只收起该卡片，历史仍保留在通知中心。通知方主动关闭时同步收起。
// 由 shell.qml 按屏创建（与 Bar 同屏，即 eDP-1）。
import QtQuick
import Quickshell
import qs

PanelWindow {
    id: win

    anchors {
        top: true
        right: true
    }
    margins {
        top: Theme.barHeight + Theme.outerMargin
        right: Theme.outerMargin
    }
    implicitWidth: 340
    implicitHeight: stack.implicitHeight
    exclusiveZone: 0
    color: "transparent"
    visible: Notifs.toasts.length > 0
    // 只让卡片区域接收点击，其余透明区域穿透
    mask: Region {
        item: stack
    }

    Column {
        id: stack
        width: parent.width
        spacing: 8

        Repeater {
            model: Notifs.toasts

            delegate: Rectangle {
                id: card

                required property var modelData
                readonly property var note: modelData.n

                // ── 出现 / 消失动画 ──────────────────────────────
                // 0 = 完全隐藏，1 = 完全显示。进场和退场共用一条时间轴：
                // 进场 0→1（toastEnterMs），到期前 1→0（toastExitMs）。
                // 退场提前在卡片被移除之前跑，所以真正删掉时视觉上已经消失了。
                property real reveal: 0
                property bool exiting: false

                opacity: card.reveal
                scale: 0.97 + 0.03 * card.reveal
                transformOrigin: Item.Top
                // 从上方 6px 处落下（跟面板动画同一套感觉），用 Translate 避免和 Column 抢几何属性
                transform: Translate { y: (1 - card.reveal) * -6 }

                Behavior on reveal {
                    NumberAnimation {
                        duration: card.exiting ? Theme.toastExitMs : Theme.toastEnterMs
                        easing.type: card.exiting ? Easing.InCubic : Easing.OutCubic
                    }
                }

                // 生命周期定时器：在到期前 toastExitMs 开始淡出
                Timer {
                    id: lifeTimer
                    interval: Math.max(0, Notifs.toastMs - (Date.now() - card.modelData.at) - Theme.toastExitMs)
                    onTriggered: {
                        card.exiting = true;
                        card.reveal = 0;
                    }
                }

                Component.onCompleted: {
                    // 下一帧再置 1，保证首帧确实从 0 开始（否则可能直接以最终态出现，看不到动画）
                    Qt.callLater(function() { card.reveal = 1; });
                    lifeTimer.start();
                }

                width: stack.width
                height: content.implicitHeight + 24
                radius: Theme.panelRadius
                color: Theme.panelBg
                border.color: Theme.pillBorder
                border.width: 1

                // 通知方主动关闭时收起卡片
                Connections {
                    target: card.note
                    function onClosed() {
                        Notifs.removeToast(card.note);
                    }
                }

                Column {
                    id: content
                    x: 12
                    y: 12
                    width: card.width - 24
                    spacing: 4

                    Text {
                        width: parent.width
                        elide: Text.ElideRight
                        text: card.note.appName || "通知"
                        textFormat: Text.PlainText
                        color: Theme.panelMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                        font.weight: Theme.fontWeight
                    }

                    Text {
                        width: parent.width
                        visible: text !== ""
                        wrapMode: Text.WordWrap
                        text: card.note.summary
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
                        text: card.note.body
                        textFormat: Text.PlainText
                        color: Theme.windowTitle
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 1
                        font.weight: Theme.fontWeight
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Notifs.removeToast(card.note)
                }
            }
        }
    }
}
