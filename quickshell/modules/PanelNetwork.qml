// 面板 · 网络：Wi-Fi 开关 + 扫描 + 网络列表（连接 / 断开 / 忘记 / 输密码）。
// 数据来自 Quickshell.Networking。信号强度挂在已连接接入点(WifiNetwork)上。
import QtQuick
import Quickshell
import Quickshell.Networking
import qs

Column {
    id: root

    readonly property var wifi: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var activeNet: root.wifi?.networks?.values?.find(n => n.connected) ?? null

    // 可连接的网络列表：按信号强度降序
    readonly property var networkList: {
        const list = (root.wifi?.networks?.values ?? []).slice();
        list.sort((a, b) => (b.signalStrength ?? 0) - (a.signalStrength ?? 0));
        return list.slice(0, 8);
    }

    // 正在等待输入密码的网络
    property var pskTarget: null
    property string pskText: ""

    // 信号强度统一换算到 0–100
    function strengthPct(net) {
        const raw = net?.signalStrength ?? 0;
        return Math.round(raw > 1 ? raw : raw * 100);
    }

    spacing: 8

    // 标题行：开关
    Row {
        width: parent.width

        Text {
            id: wifiLabel
            text: "Wi-Fi"
            color: Theme.network
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            width: parent.width - wifiLabel.implicitWidth - wifiToggle.width
            height: 1
        }

        PanelToggle {
            id: wifiToggle
            anchors.verticalCenter: parent.verticalCenter
            checked: Networking.wifiEnabled
            enabledState: root.wifi !== null && Networking.wifiHardwareEnabled
            onToggled: v => {
                Networking.wifiEnabled = v;
            }
        }
    }

    // 当前连接 + 断开
    Row {
        width: parent.width
        spacing: 6
        visible: root.activeNet !== null

        Text {
            width: parent.width - discBtn.width - 8
            elide: Text.ElideRight
            anchors.verticalCenter: parent.verticalCenter
            text: "已连接  " + (root.activeNet?.name ?? "") + "  ·  " + root.strengthPct(root.activeNet) + "%"
            color: Theme.windowTitle
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize - 1
            font.weight: Theme.fontWeight
        }

        PanelButton {
            id: discBtn
            text: "断开"
            accent: Theme.battery
            onClicked: {
                if (root.activeNet) root.activeNet.disconnect();
            }
        }
    }

    // 扫描按钮
    Row {
        width: parent.width
        spacing: 6

        PanelButton {
            text: (root.wifi?.scannerEnabled ?? false) ? "停止扫描" : "扫描网络"
            accent: Theme.network
            armed: Networking.wifiEnabled && root.wifi !== null
            onClicked: {
                if (!root.wifi) return;
                root.wifi.scannerEnabled = !root.wifi.scannerEnabled;
            }
        }
    }

    // 密码输入行
    Row {
        width: parent.width
        spacing: 6
        visible: root.pskTarget !== null

        Rectangle {
            width: parent.width - pskOk.width - pskCancel.width - 12
            height: 24
            radius: 7
            color: Qt.rgba(1, 1, 1, 0.07)

            TextInput {
                id: pskInput
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                color: Theme.panelText
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize - 2
                font.weight: Theme.fontWeight
                selectByMouse: true
                onTextChanged: root.pskText = text
                Keys.onReturnPressed: root.pskOk()

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: parent.text.length === 0
                    text: "输入 Wi-Fi 密码"
                    color: Theme.panelMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                }
            }
        }

        PanelButton {
            id: pskOk
            text: "连接"
            accent: Theme.network
            onClicked: root.pskOk()
        }

        PanelButton {
            id: pskCancel
            text: "取消"
            onClicked: {
                root.pskTarget = null;
                root.pskText = "";
            }
        }
    }

    function pskOk() {
        if (!root.pskTarget) return;
        root.pskTarget.connectWithPsk(root.pskText);
        root.pskTarget = null;
        root.pskText = "";
    }

    // 提示
    Text {
        width: parent.width
        wrapMode: Text.WordWrap
        visible: root.networkList.length === 0
        text: {
            if (root.wifi === null) return "无 Wi-Fi 设备";
            if (!Networking.wifiEnabled) return "Wi-Fi 已关闭";
            return (root.wifi?.scannerEnabled ?? false) ? "正在扫描…" : "未发现网络，点击「扫描网络」";
        }
        color: Theme.panelMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
        font.weight: Theme.fontWeight
    }

    // 网络列表
    Repeater {
        model: root.networkList

        delegate: Column {
            id: netRow
            required property var modelData
            width: root.width
            spacing: 4

            Row {
                width: parent.width
                spacing: 6

                Text {
                    width: parent.width - sigLabel.implicitWidth - 8
                    elide: Text.ElideRight
                    text: (netRow.modelData.connected ? "\uF1EB " : "\uF1EB ") + (netRow.modelData.name || "未知网络")
                    color: netRow.modelData.connected ? Theme.network : Theme.panelText
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 1
                    font.weight: Theme.fontWeight
                }

                Text {
                    id: sigLabel
                    text: root.strengthPct(netRow.modelData) + "%"
                    color: Theme.panelMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 3
                    font.weight: Theme.fontWeight
                }
            }

            Row {
                spacing: 6

                // 未连接：连接
                PanelButton {
                    visible: !netRow.modelData.connected
                    text: netRow.modelData.known ? "连接" : "连接(需密码)"
                    accent: Theme.network
                    onClicked: {
                        if (netRow.modelData.known) {
                            netRow.modelData.connect();
                        } else {
                            root.pskTarget = netRow.modelData;
                            root.pskText = "";
                            pskInput.text = "";
                            pskInput.forceActiveFocus();
                        }
                    }
                }

                // 已连接：断开
                PanelButton {
                    visible: netRow.modelData.connected
                    text: "断开"
                    accent: Theme.battery
                    onClicked: netRow.modelData.disconnect()
                }

                // 已保存：忘记
                PanelButton {
                    visible: netRow.modelData.known && !netRow.modelData.connected
                    text: "忘记"
                    accent: Theme.notifyUnread
                    onClicked: netRow.modelData.forget()
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(1, 1, 1, 0.07)
            }
        }
    }
}
