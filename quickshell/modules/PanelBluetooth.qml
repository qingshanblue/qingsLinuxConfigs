// 面板 · 蓝牙：开关 + 扫描 + 设备列表（配对/连接/断开/取消配对）。
// 数据来自 Quickshell.Bluetooth，全部为属性绑定，事件驱动，无轮询。
import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs

Column {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter

    // 设备列表：按 已连接 > 已配对 > 其他 排序，最多显示 8 个避免面板过长
    readonly property var deviceList: {
        const list = (Bluetooth.devices?.values ?? []).slice();
        list.sort((a, b) => {
            const rank = d => d.connected ? 0 : (d.paired ? 1 : 2);
            const r = rank(a) - rank(b);
            if (r !== 0) return r;
            return (a.name ?? "").localeCompare(b.name ?? "");
        });
        return list.slice(0, 8);
    }

    spacing: 8

    // 标题行：开关
    Row {
        width: parent.width

        Text {
            id: btLabel
            text: "蓝牙"
            color: Theme.audio
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            width: parent.width - btLabel.implicitWidth - btToggle.width
            height: 1
        }

        PanelToggle {
            id: btToggle
            anchors.verticalCenter: parent.verticalCenter
            checked: root.adapter?.enabled ?? false
            enabledState: root.adapter !== null
            onToggled: v => {
                if (root.adapter) root.adapter.enabled = v;
            }
        }
    }

    // 扫描按钮
    Row {
        width: parent.width
        spacing: 6

        PanelButton {
            text: (root.adapter?.discovering ?? false) ? "停止扫描" : "扫描设备"
            accent: Theme.audio
            armed: (root.adapter?.enabled ?? false)
            onClicked: {
                if (!root.adapter) return;
                root.adapter.discovering = !root.adapter.discovering;
            }
        }

        PanelButton {
            text: "刷新"
            armed: (root.adapter?.enabled ?? false)
            onClicked: {
                if (!root.adapter) return;
                // 触发一次扫描开关，让后端重新枚举
                root.adapter.discovering = false;
                root.adapter.discovering = true;
            }
        }
    }

    // 提示文字
    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        visible: root.deviceList.length === 0
        text: {
            if (root.adapter === null) return "无蓝牙适配器";
            if (!root.adapter.enabled) return "蓝牙已关闭";
            return (root.adapter.discovering ?? false) ? "正在扫描附近设备…" : "无设备，点击「扫描设备」";
        }
        color: Theme.panelMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
        font.weight: Theme.fontWeight
    }

    // 设备列表
    Repeater {
        model: root.deviceList

        delegate: Column {
            id: row
            required property var modelData
            width: root.width
            spacing: 4

            // 名称行
            Row {
                width: parent.width
                spacing: 6

                Text {
                    width: parent.width - stateLabel.implicitWidth - 8
                    elide: Text.ElideRight
                    text: (row.modelData.connected ? "\uF293 " : "\uF294 ") + (row.modelData.name || row.modelData.address || "未知设备")
                    color: row.modelData.connected ? Theme.audio : Theme.panelText
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                    font.weight: Theme.fontWeight
                }

                Text {
                    id: stateLabel
                    text: row.modelData.connected ? "已连接"
                        : row.modelData.paired ? "已配对"
                        : (row.modelData.pairing ? "配对中" : "")
                    color: Theme.panelMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 3
                    font.weight: Theme.fontWeight
                }
            }

            // 操作行
            Row {
                spacing: 6

                // 未配对：配对
                PanelButton {
                    visible: !row.modelData.paired
                    text: "配对"
                    accent: Theme.audio
                    onClicked: row.modelData.pair()
                }

                // 已配对未连接：连接
                PanelButton {
                    visible: row.modelData.paired && !row.modelData.connected
                    text: "连接"
                    accent: Theme.network
                    onClicked: row.modelData.connect()
                }

                // 已连接：断开
                PanelButton {
                    visible: row.modelData.connected
                    text: "断开"
                    accent: Theme.battery
                    onClicked: row.modelData.disconnect()
                }

                // 已配对：取消配对
                PanelButton {
                    visible: row.modelData.paired
                    text: "取消配对"
                    accent: Theme.notifyUnread
                    onClicked: row.modelData.forget()
                }
            }

            // 分隔
            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(1, 1, 1, 0.07)
            }
        }
    }
}
