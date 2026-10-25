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

    // 左药丸里除窗口标题外的宽度（时钟+魔法棒+工作区+间距+内边距）
    readonly property real leftOthersWidth: {
        let w = Theme.pillPadding * 2 + Theme.spacing * 3;
        w += clockMod.implicitWidth + scratchpadMod.implicitWidth + workspacesMod.implicitWidth;
        return w;
    }

    // 中区药丸宽度上限（左区避让与中区自身共用同一数值，避免两处不一致）
    readonly property int centerMaxWidth: Math.max(64, Math.min(260, Math.round(bar.width * 0.22)))
    readonly property int centerHalf: Math.round(bar.centerMaxWidth / 2)

    // 本屏的输出名（如 eDP-1），供工作区过滤使用
    readonly property string monitorName: bar.screen?.name ?? ""

    // 中区药丸左缘的 x 坐标（绝对居中：屏幕中线 - 半宽）。
    // 关键：不读 centerPill.x（anchored，读它会把「左药丸宽度 → 标题宽 → 中区位置」连成回路），
    //      而是用屏幕中线与中区宽度直接算出，中区宽度只由内容/上限决定，与左药丸无关。
    readonly property real centerLeftX: bar.width / 2 - centerPill.width / 2

    // 窗口标题可用的像素宽度。
    // 布局预算（绝对 x 坐标，从屏幕左边算）：
    //   左药丸左缘 = outerMargin
    //   左药丸右缘 = outerMargin + leftOthersWidth + titleWidth
    //   要求：左药丸右缘 + 呼吸间距 <= 中区左缘
    //   ⇒ titleWidth <= centerLeftX - gap - outerMargin - leftOthersWidth
    // 注意：leftOthersWidth 已含 spacing*3（时钟/魔法棒/工作区/标题四个元素间的三个间隙），
    //      因此这里不能再加任何 padding/spacing 修正项，否则会与旧实现一样相互抵消、
    //      算出的宽度让标题直接顶到中区药丸。
    // 同样完全不引用 leftPill.width，不会形成绑定回路。
    readonly property int titleGap: 12   // 标题右端与中区左缘之间的呼吸间距
    readonly property real titleRoomWidth: {
        const centerEdge = centerPill.visible ? bar.centerLeftX - bar.titleGap : bar.width / 2 - 6;
        const leftEdge = Theme.outerMargin + bar.leftOthersWidth;
        return Math.max(40, Math.floor(centerEdge - leftEdge));
    }

    // ---- 左区 ----
    Pill {
        id: leftPill
        anchors.left: parent.left
        anchors.leftMargin: Theme.outerMargin
        anchors.verticalCenter: parent.verticalCenter
        // 左药丸整体不得越过「中区左缘 - 呼吸间距」。
        // 注意：必须与 titleRoomWidth 用同一基准（centerLeftX，即中区按【当前实际宽度】算的左缘），
        //      旧值 bar.width/2 - centerHalf - 8 是按中区【最大宽度】估的，比实际更靠左：
        //      中区较窄时药丸底色被提前截短，而 Row 仍按自然宽度排版 → 文字探出药丸。
        widthLimit: bar.centerLeftX - bar.titleGap - Theme.outerMargin

        Clock {
            id: clockMod
            hostWindow: bar
        }
        ScratchpadButton {
            id: scratchpadMod
        }
        Workspaces {
            id: workspacesMod
            monitorName: bar.monitorName
        }
        ActiveWindow {
            // 动态避让：标题宽度 = 中区左缘到左药丸左缘的空间 - 其他模块占用。
            // 中区药丸宽度是动态的，所以这里也必须是响应式绑定；
            // 但绑定链不能反向依赖 leftPill.width（会 polish 回路），见 titleRoomWidth。
            maxWidth: bar.titleRoomWidth
        }
    }

    // ---- 连接线：一条真实的点状线，从左药丸到右药丸 ----------------
    // 整条线一次绘制，点距均匀；中区药丸用同底色矩形盖住中间一段，
    // 视觉上是"一条线被药丸截断"，而不是两段拼凑。
    Item {
        id: dotLine
        anchors.left: leftPill.right
        anchors.leftMargin: 12
        anchors.right: rightPill.left
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        height: 9

        readonly property int spacing: 10
        readonly property int dotCount: Math.max(1, Math.floor((width - 4) / spacing))

        // 中区药丸在本线坐标系里的左右边界（用于逐点隐藏）
        readonly property real centerLeft: centerPill.visible
            ? centerPill.mapToItem(dotLine, 0, 0).x - 5 : Infinity
        readonly property real centerRight: centerPill.visible
            ? centerPill.mapToItem(dotLine, centerPill.width, 0).x + 5 : -Infinity

        Repeater {
            model: dotLine.dotCount
            delegate: Rectangle {
                required property int index
                width: 3
                height: 3
                radius: 1.5
                x: index * dotLine.spacing + 2
                anchors.verticalCenter: parent.verticalCenter
                color: Qt.rgba(0, 0, 0, 0.5)

                // 中区药丸若覆盖此点，则隐藏
                readonly property real cx: x + 1.5
                visible: cx < dotLine.centerLeft || cx > dotLine.centerRight
            }
        }

        // 屏幕正中点：中区无媒体时在此处画一个小菱形（唯一装饰）
        Rectangle {
            visible: !centerPill.visible
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: 7
            height: 7
            rotation: 45
            color: Qt.rgba(0, 0, 0, 0.5)
        }
    }

    // ---- 中区：媒体播放（普通药丸，与左右同高；无播放器时不显示） ----
    // 不用 Pill：Pill 的内部 Row 不允许子项居中锚定。这里自绘同款药丸。
    Rectangle {
        id: centerPill
        visible: mediaMod.hasMedia
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        // 药丸宽度完全由 Media 决定（内容自然宽 → 上限），宽度变化带动画
        implicitWidth: Math.min(mediaMod.implicitWidth, mediaMod.availWidth)
        implicitHeight: Theme.pillHeight
        radius: height / 2
        color: Theme.pillBg
        border.color: Theme.pillBorder
        border.width: 1

        // 换歌 / 切形态时药丸宽度平滑伸缩（滚动中不动画，避免抖动）
        Behavior on implicitWidth {
            enabled: !mediaMod.needScroll
            NumberAnimation { duration: 240; easing.type: Easing.OutCubic }
        }

        Media {
            id: mediaMod
            hostWindow: bar
            anchors.centerIn: parent
            // 中区药丸【外框】宽度上限（含内边距）。绝对居中。
            // 重要：不能用 leftPill.width 算可用空间——左区标题宽度反向依赖中区宽度，
            //      会形成绑定回路（leftPill.width → 标题宽 → 中区位置 → leftPill.width）。
            //      因此这里用与左区无关的屏幕百分比预算，左区再用 titleRoomWidth 反向避让。
            availWidth: bar.centerMaxWidth
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
