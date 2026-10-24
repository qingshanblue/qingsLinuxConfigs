// 状态栏窗口：一个 PanelWindow，三个深色药丸。左：时钟/魔法棒/工作区/标题；中：保留容器但隐藏；右：托盘/蓝牙/网络/音量/亮度/电池/通知。
// 每个模块点击唤出自己的面板（ControlPanel 按 panelKind 切换内容）。窗口透明，只有药丸可见。
import Quickshell
import QtQuick
import "modules"
import qs

PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Theme.barHeight
    // 预留空间，使普通窗口不被遮挡。注意：与 wayle 同时运行会重复预留，切换时只开其一。
    exclusiveZone: Theme.barHeight
    color: "transparent"

    // 本屏的输出名（如 eDP-1），供工作区过滤使用
    readonly property string monitorName: bar.screen?.name ?? ""

    // ---- 左区 ----
    Pill {
        id: leftPill
        anchors.left: parent.left
        anchors.leftMargin: Theme.outerMargin
        anchors.verticalCenter: parent.verticalCenter

        Clock {}
        ScratchpadButton {}
        Workspaces {
            monitorName: bar.monitorName
        }
        ActiveWindow {
            // 按屏幕宽度限制标题最大宽度，避免超长标题顶到右侧药丸
            maxWidth: Math.max(120, Math.round(bar.width * 0.22))
        }
    }

    // ---- 中区 ----
    // 连接左右两个药丸的点状线：一列小圆点，越靠两端越淡，正中放一个小菱形做视觉落点
    Item {
        id: middleLine
        anchors.left: leftPill.right
        anchors.right: rightPill.left
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        height: 8

        // 点的间距 9px，按可用宽度算个数
        readonly property int dotCount: Math.max(0, Math.floor(width / 11))

        Repeater {
            model: middleLine.dotCount

            Rectangle {
                required property int index

                width: 3
                height: 3
                radius: 1.5
                x: index * 11 + 4
                anchors.verticalCenter: parent.verticalCenter
                color: Qt.rgba(0, 0, 0, 0.55)

                // 离中点越远越淡，两端完全消失
                readonly property real centerIdx: (middleLine.dotCount - 1) / 2
                readonly property real dist: Math.abs(index - centerIdx) / Math.max(1, centerIdx)
                opacity: Math.max(0, 1 - dist * dist * 1.15)
            }
        }

        // 正中菱形
        Rectangle {
            anchors.centerIn: parent
            width: 7
            height: 7
            rotation: 45
            color: Qt.rgba(0, 0, 0, 0.55)
        }
    }

    // 一次性几何诊断：启动 3 秒后把药丸与连接线的实际宽度写入 quickshell 日志，供排查"看不到线"
    Timer {
        interval: 3000
        running: true
        onTriggered: {
            console.log("LAYOUT leftPill.right=" + leftPill.x + "+" + leftPill.width
                + " rightPill.x=" + rightPill.x + " midWidth=" + middleLine.width
                + " midVisible=" + middleLine.visible);
        }
    }

    // ---- 右区 ----
    // 点击层：放在右区药丸的【下方】（先声明=层级更低）。药丸本身不接收点击，
    // 因此托盘图标/把手的点击仍由它们自己处理，其余点击穿透到这里，用于打开控制面板。
    MouseArea {
        id: panelTrigger
        anchors.fill: rightPill
        onClicked: mouse => {
            const hit = bar.moduleAt(mouse.x);
            // 由模块自身声明面板类型；没有 panelKind 的（托盘、空隙）不触发面板
            const k = hit.panelKind ?? "";
            if (k === "") return;
            controlPanel.openPanel(k, hit);
        }
    }

    Pill {
        id: rightPill
        anchors.right: parent.right
        anchors.rightMargin: Theme.outerMargin
        anchors.verticalCenter: parent.verticalCenter

        Tray {
            id: trayMod
            bar: bar
            onMenuRequested: (item, anchorItem) => trayMenu.openFor(item, anchorItem)
        }
        BluetoothIcon {
            id: bluetoothMod
        }
        Network {
            id: networkMod
        }
        Volume {
            id: volumeMod
        }
        Brightness {
            id: brightnessMod
        }
        Battery {
            id: batteryMod
        }
        // 通知按钮：最右侧。左键唤出通知中心，右键切换勿扰（NotifyButton 自行处理点击）
        NotifyButton {
            id: notifyMod
            onActivated: controlPanel.openPanel(notifyMod.panelKind, notifyMod)
        }
    }

    // 托盘右键菜单（自绘，锚定到被点击的图标）
    TrayMenu {
        id: trayMenu
    }

    // 控制面板（PopupWindow），锚定到 bar 窗口，锚点模块与类型由 openPanel 传入
    ControlPanel {
        id: controlPanel
        anchor.window: bar
        brightnessPercent: brightnessMod.percent
        onBrightnessChanged: brightnessMod.refresh()
    }

    // 返回落在右区哪个模块上的 x 坐标范围内的模块；落在空隙上返回右区药丸本身
    function moduleAt(x) {
        const mods = [trayMod, bluetoothMod, networkMod, volumeMod, brightnessMod, batteryMod];
        for (let i = 0; i < mods.length; i++) {
            const m = mods[i];
            const p = m.mapToItem(rightPill, 0, 0);
            if (x >= p.x && x < p.x + m.width) return m;
        }
        return rightPill;
    }
}
