// 托盘右键菜单：Quickshell 自绘，锚定到被点击的图标正下方。
// 不再使用 SystemTrayItem.display()（那是 GTK 平台菜单，在 layer-shell 窗口上位置会跑偏），
// 改为读 DBusMenu 的菜单树自己渲染，并用 DBusMenuItem.sendTriggered() 触发。
import QtQuick
import Quickshell
import Quickshell.DBusMenu
import Quickshell.Widgets
import qs

PopupWindow {
    id: menu

    // 被点击的托盘项（SystemTrayItem）
    property var targetItem: null
    // 锚定用的图标对象（IconImage/Item）
    property var anchorItem: null
    // 当前菜单层级：空数组=根，否则是逐级下钻的 DBusMenuItem
    property var menuStack: []

    // 根菜单：SystemTrayItem.menu 本身就是 DBusMenuHandle，而 DBusMenuHandle 继承自 QsMenuHandle，
    // 可以直接交给 QsMenuOpener（多取一层 .menu 会拿到 null，因为根项是懒加载的）。
    readonly property var currentHandle: menuStack.length > 0
        ? menuStack[menuStack.length - 1]
        : (targetItem?.menu ?? null)

    anchor.item: anchorItem
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 6
    // 贴边时左右滑回屏幕内；下方空间不足时翻到上方
    anchor.adjustment: PopupAdjustment.SlideX | PopupAdjustment.FlipY

    visible: false
    // 抓取焦点：点击面板外时合成器发出 popup_done，窗口才能自动关闭
    grabFocus: true
    color: "transparent"
    implicitWidth: panel.implicitWidth
    implicitHeight: panel.implicitHeight

    // 菜单树（children 为 DBusMenuItem 列表）
    QsMenuOpener {
        id: opener
        menu: menu.currentHandle
    }

    // 触发一个菜单项。sendTriggered 仅存在于 DBusMenuItem，调用前先判断，避免类型错误。
    function trigger(entry) {
        if (entry.hasChildren) {
            // 有子菜单：下钻一层
            const s = menu.menuStack.slice();
            s.push(entry);
            menu.menuStack = s;
            return;
        }
        if (typeof entry.sendTriggered === "function") entry.sendTriggered();
        menu.close();
    }

    function back() {
        const s = menu.menuStack.slice();
        s.pop();
        menu.menuStack = s;
    }

    function openFor(item, anchorObj) {
        menu.targetItem = item;
        menu.anchorItem = anchorObj;
        menu.menuStack = [];
        menu.visible = true;

        // 诊断：记录菜单树是否真的拿到了。DBusMenu 布局是异步加载的，需延迟再查一次。
        console.log("TRAYPROBE open title=" + (item?.title ?? "?")
            + " hasMenu=" + (item?.hasMenu ?? "?")
            + " handle=" + (item?.menu ? "obj" : "null"));
        probeTimer.restart();
    }

    // 打开 800ms 后再记录一次 children 数量（此时异步布局应该已就绪）
    Timer {
        id: probeTimer
        interval: 800
        running: false
        onTriggered: {
            console.log("TRAYPROBE after800 opener.menu=" + (opener.menu ? "obj" : "null")
                + " repeaterCount=" + entryRepeater.count);
        }
    }

    function close() {
        menu.visible = false;
        menu.menuStack = [];
    }

    // 点面板外被合成器关闭时，同步清理层级
    onClosed: menu.menuStack = []

    Rectangle {
        id: panel

        implicitWidth: Math.max(180, col.implicitWidth + 20)
        implicitHeight: col.implicitHeight + 12
        radius: 10
        color: Qt.rgba(18 / 255, 18 / 255, 18 / 255, 0.96)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.10)

        Column {
            id: col
            x: 10
            y: 6
            width: parent.width - 20
            spacing: 0

            // 子菜单时提供返回项
            Rectangle {
                visible: menu.menuStack.length > 0
                width: col.width
                height: visible ? 24 : 0
                color: "transparent"

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "‹  返回"
                    color: Theme.wsEmptyText
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: menu.back()
                }
            }

            Repeater {
                id: entryRepeater
                model: opener.children

                delegate: Item {
                    id: row

                    required property var modelData

                    width: col.width
                    // 分隔线占 7px，普通项占 24px
                    height: (modelData.isSeparator ?? false) ? 7 : 24

                    // 分隔线
                    Rectangle {
                        visible: modelData.isSeparator ?? false
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 1
                        color: Qt.rgba(1, 1, 1, 0.10)
                    }

                    // 菜单项内容
                    Row {
                        visible: !(modelData.isSeparator ?? false)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8

                        // 图标：取不到就只显示文字（不占位）
                        Item {
                            id: iconSlot
                            width: 14
                            height: 14
                            // 只有真正解析到图标才占位，否则不留空档
                            readonly property string iconSrc: {
                                const n = modelData.icon ?? "";
                                if (n === "") return "";
                                if (n.startsWith("/")) return n;
                                return Quickshell.iconPath(n, true) ?? "";
                            }
                            visible: iconSrc !== ""

                            IconImage {
                                anchors.fill: parent
                                source: iconSlot.iconSrc
                                implicitSize: 14
                            }
                        }

                        Text {
                            text: modelData.text ?? ""
                            color: (modelData.enabled ?? true) ? Theme.panelText : Theme.wsEmptyText
                            font.family: Theme.fontFamily
                            font.pixelSize: 12
                            // 有子菜单时给出提示
                            // (右箭头用 Nerd Font 的 md-chevron-right)
                            // 注意：DBusMenuItem.hasChildren 为 true 时点击是下钻而不是触发
                        }

                        Text {
                            visible: modelData.hasChildren ?? false
                            text: "󰅂"
                            color: Theme.wsEmptyText
                            font.family: Theme.fontFamily
                            font.pixelSize: 10
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: !(modelData.isSeparator ?? false) && (modelData.enabled ?? true)
                        cursorShape: Qt.PointingHandCursor
                        onClicked: menu.trigger(modelData)
                    }
                }
            }

            // 空菜单兜底。注意：UntypedObjectModel 没有 length/count 属性，
            // 必须用 Repeater.count 判断是否真的为空（用 children.length 会恒为 undefined）。
            Text {
                visible: entryRepeater.count === 0
                width: col.width
                text: "（无菜单项）"
                color: Theme.wsEmptyText
                font.family: Theme.fontFamily
                font.pixelSize: 12
            }
        }
    }
}
