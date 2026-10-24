// 面板 · 电源档位：省电 / 平衡 / 性能 三个按钮，高亮当前档位。
// 通过 powerprofilesctl 读写（Process，不轮询）：面板打开时读一次，点击后写入并再读回校验。
import QtQuick
import Quickshell.Io
import qs

Column {
    id: root

    // 当前档位：power-saver / balanced / performance，空串表示未知
    property string current: ""
    property bool readFailed: false

    // 档位定义：内部值 -> 显示文字
    readonly property var profiles: [
        { key: "power-saver", label: "省电" },
        { key: "balanced", label: "平衡" },
        { key: "performance", label: "性能" }
    ]

    // 外部调用：重新读取当前档位（面板每次打开时调用一次）
    function refresh() {
        getProc.running = true;
    }

    function setProfile(key) {
        root.current = key;   // 乐观更新，随后由读回结果校正
        setProc.command = ["powerprofilesctl", "set", key];
        setProc.running = true;
    }

    spacing: 8

    Text {
        text: "电源档位"
        color: Theme.battery
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
    }

    Row {
        width: parent.width
        spacing: 6

        Repeater {
            model: root.profiles

            delegate: Rectangle {
                required property var modelData

                readonly property bool active: root.current === modelData.key

                width: (root.width - 2 * 6) / 3
                height: Theme.pillHeight
                radius: height / 2
                color: active ? Theme.wsActiveBg : Qt.rgba(1, 1, 1, 0.08)

                Text {
                    anchors.centerIn: parent
                    text: modelData.label
                    color: parent.active ? Theme.wsActiveText : Theme.windowTitle
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    font.weight: Theme.fontWeight
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.setProfile(parent.modelData.key)
                }
            }
        }
    }

    Text {
        visible: root.readFailed
        text: "无法读取档位（powerprofilesctl 失败）"
        color: Theme.panelMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
        font.weight: Theme.fontWeight
    }

    // 读取当前档位
    Process {
        id: getProc
        command: ["powerprofilesctl", "get"]
        stdout: StdioCollector {
            id: getOut
            onStreamFinished: root.current = getOut.text.trim()
        }
        onExited: code => root.readFailed = code !== 0
    }

    // 写入档位；写完后再读一次，以实际结果为准
    Process {
        id: setProc
        onExited: code => {
            root.readFailed = code !== 0;
            getProc.running = true;
        }
    }
}
