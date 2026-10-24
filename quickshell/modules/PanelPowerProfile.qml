// 面板 · 电源档位：省电 / 平衡 / 性能 三个按钮，高亮当前档位。
// 走 Quickshell.Services.UPower 的原生 D-Bus 接口（power-profiles-daemon），
// 不调用 powerprofilesctl，属性变化自动刷新。
import QtQuick
import Quickshell.Services.UPower
import qs

Column {
    id: root

    // 档位定义：枚举值 -> 显示文字
    readonly property var profiles: [
        { value: PowerProfile.PowerSaver, label: "省电" },
        { value: PowerProfile.Balanced, label: "平衡" },
        { value: PowerProfile.Performance, label: "性能" }
    ]

    // 当前档位（原生属性，自动跟随 daemon 变化）
    readonly property int current: PowerProfiles.profile ?? -1
    readonly property bool hasPerformance: PowerProfiles.hasPerformanceProfile ?? true

    // 面板打开时的钩子（保留接口，原生绑定后无需主动读取）
    function refresh() {}

    function setProfile(value) {
        PowerProfiles.profile = value;
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

                readonly property bool active: root.current === modelData.value

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
                    onClicked: root.setProfile(modelData.value)
                }
            }
        }
    }

    // 不支持性能档位时的提示
    Text {
        visible: !root.hasPerformance
        text: "此设备不支持「性能」档位"
        color: Theme.panelMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
        font.weight: Theme.fontWeight
    }
}
