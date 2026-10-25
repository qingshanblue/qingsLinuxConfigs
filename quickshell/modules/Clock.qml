// 时钟 + 日历 / 秒表 / 定时器 / 闹钟 弹窗
// 所有计时状态放在 Timers 单例里，两块屏幕共享同一份状态。
// 数据：农历与节日来自 Lunar 单例；时间来自 Timers.now。
import QtQuick
import Quickshell
import qs

Item {
    id: root

    // 弹窗锚定的状态栏窗口（由 Bar 赋值到 popup.anchor.window）
    property var hostWindow: null
    readonly property alias popup: cal

    readonly property var weekNames: ["日", "一", "二", "三", "四", "五", "六"]

    // 弹窗页面：0=日历 1=秒表 2=定时器 3=闹钟
    property int page: 0
    // 日历开关直接别名到动画控制器（唯一状态源）：
    // 打开/收起、出现/消失动画都由 PanelAnim 负责，避免两份布尔状态不同步。
    property alias calOpen: cal.anim.open

    // 月历浏览的年月
    property int calYear: Timers.now.getFullYear()
    property int calMonth: Timers.now.getMonth()

    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    // ── 日期工具 ──
    function firstWeekday(y, m) { return new Date(y, m, 1).getDay(); }
    function daysInMonth(y, m) { return new Date(y, m + 1, 0).getDate(); }

    readonly property var calCells: {
        const out = [];
        const first = root.firstWeekday(root.calYear, root.calMonth);
        const days = root.daysInMonth(root.calYear, root.calMonth);
        for (let i = 0; i < first; i++) out.push(0);
        for (let d = 1; d <= days; d++) out.push(d);
        while (out.length < 42) out.push(0);
        return out;
    }

    function prevMonth() {
        let m = root.calMonth - 1, y = root.calYear;
        if (m < 0) { m = 11; y -= 1; }
        root.calMonth = m; root.calYear = y;
    }
    function nextMonth() {
        let m = root.calMonth + 1, y = root.calYear;
        if (m > 11) { m = 0; y += 1; }
        root.calMonth = m; root.calYear = y;
    }
    function backToToday() {
        root.calYear = Timers.now.getFullYear();
        root.calMonth = Timers.now.getMonth();
    }

    // ── 状态栏图标：允许同时显示多个 ──
    readonly property var activeIcons: {
        const list = [];
        if (Timers.alRinging) list.push({ t: "󰀠", c: Theme.notifyUnread });
        else if (Timers.alEnabled) list.push({ t: "󰀠", c: Theme.audio });
        if (Timers.tmRinging) list.push({ t: "󰅶", c: Theme.notifyUnread });
        else if (Timers.tmRunning) list.push({ t: "󱎫", c: Theme.magic });
        if (Timers.swRunning) list.push({ t: "󰔚", c: Theme.magic });
        return list;
    }

    // ── 状态栏内容 ──
    Row {
        id: row
        spacing: 4

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            text: Qt.formatTime(Timers.now, "HH:mm")
            color: Theme.clockText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
        }

        // 多种状态可同时显示
        Row {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Repeater {
                model: root.activeIcons

                delegate: Text {
                    required property var modelData
                    text: modelData.t
                    color: modelData.c
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                }
            }
        }
    }

    MouseArea {
        id: hover
        anchors.fill: row
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (!root.calOpen) root.backToToday();
            root.calOpen = !root.calOpen;
        }
    }

    // 悬停提示（日历打开时不显示，避免重叠）
    PopupWindow {
        id: tip

        // 出现/消失动画控制器
        property PanelAnim anim: PanelAnim { target: tip }

        visible: anim.surfaced
        color: "transparent"
        implicitWidth: tipText.implicitWidth + 16
        implicitHeight: tipText.implicitHeight + 8

        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom

        // 悬浮提示用根判断开关：鼠标悬停且日历未开
        Binding { target: tip.anim; property: "open"; value: hover.containsMouse && !root.calOpen }

        Rectangle {
            id: tipRect
            // 不用 anchors.fill：y 要参与动画，改用显式几何
            x: 0
            width: parent.width
            height: parent.height
            opacity: tip.anim.progress
            scale: tip.anim.scaleFrom + (1 - tip.anim.scaleFrom) * tip.anim.progress
            y: tip.anim.offsetY * (1 - tip.anim.progress)
            transformOrigin: Item.Top
            radius: 6
            color: Theme.pillBg
            border.color: Theme.pillBorder
            border.width: 1

            Text {
                id: tipText
                anchors.centerIn: parent
                text: {
                    const d = Timers.now;
                    return d.getFullYear() + "年" + (d.getMonth() + 1) + "月" + d.getDate()
                        + "日 星期" + root.weekNames[d.getDay()];
                }
                color: Theme.clockText
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: Theme.fontWeight
            }
        }
    }

    // ══════════════ 主弹窗 ══════════════
    PopupWindow {
        id: cal

        // 出现/消失动画控制器
        property PanelAnim anim: PanelAnim { target: cal }

        visible: anim.surfaced
        color: "transparent"
        implicitWidth: 250
        implicitHeight: 310

        // 与右侧模块面板一致的锚定方式
        anchor.item: root
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.adjustment: PopupAdjustment.SlideX
        // 恒定 true：PopupWindow 的抓取必须与「表面创建」同一时刻生效，绑到会变化的
        // 属性上（曾写成 anim.open）会让抓取请求与表面映射竞争而被丢弃，
        // 表现为「点面板外关不掉」。抓取的存续由 visible: anim.surfaced 控制。
        grabFocus: true

        // root.calOpen 已是 cal.anim.open 的别名，无需额外同步

        Rectangle {
            id: calRect
            // 不用 anchors.fill：y 要参与动画，改用显式几何
            x: 0
            width: parent.width
            height: parent.height
            opacity: cal.anim.progress
            scale: cal.anim.scaleFrom + (1 - cal.anim.scaleFrom) * cal.anim.progress
            y: cal.anim.offsetY * (1 - cal.anim.progress)
            transformOrigin: Item.Top
            radius: 10
            color: Theme.panelBg
            border.color: Theme.pillBorder
            border.width: 1

            // ── 页面容器：统一留出底部翻页栏高度，内容垂直居中 ──
            Item {
                anchors.fill: parent
                anchors.bottomMargin: 26
            }

            // ══ 日历页 ══
            Column {
                id: calBody
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -12
                spacing: 5
                visible: root.page === 0

                Item {
                    width: parent.width
                    height: 24

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: "‹"
                        color: Theme.panelMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 2
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.prevMonth()
                        }
                    }

                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: "›"
                        color: Theme.panelMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 2
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.nextMonth()
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: root.calYear + " 年 " + (root.calMonth + 1) + " 月"
                        color: Theme.clockText
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 1
                        font.weight: Theme.fontWeight
                    }
                }

                Row {
                    width: parent.width
                    Repeater {
                        model: ["日", "一", "二", "三", "四", "五", "六"]
                        delegate: Text {
                            required property var modelData
                            width: calBody.width / 7
                            horizontalAlignment: Text.AlignHCenter
                            text: modelData
                            color: Theme.panelMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 3
                        }
                    }
                }

                Column {
                    width: parent.width
                    spacing: 1

                    Repeater {
                        model: 6

                        delegate: Row {
                            id: weekRow
                            required property int index
                            width: calBody.width
                            property int base: weekRow.index * 7

                            Repeater {
                                model: 7

                                delegate: Item {
                                    id: cell
                                    required property int index

                                    readonly property int day: root.calCells[weekRow.base + cell.index] ?? 0
                                    readonly property bool isToday: cell.day > 0
                                        && cell.day === Timers.now.getDate()
                                        && root.calMonth === Timers.now.getMonth()
                                        && root.calYear === Timers.now.getFullYear()

                                    readonly property var info: {
                                        if (cell.day <= 0) return null;
                                        const d = new Date(root.calYear, root.calMonth, cell.day, 12);
                                        const l = Lunar.solarToLunar(d);
                                        return {
                                            fest: Lunar.festivalOf(d),
                                            term: Lunar.solarTermOf(d),
                                            label: l ? (l.day === 1 ? l.monthName : l.dayName) : ""
                                        };
                                    }
                                    readonly property string festText: info ? (info.fest ?? "") : ""
                                    readonly property string termText: info ? (info.term ?? "") : ""
                                    readonly property string lunarText: info ? (info.label ?? "") : ""
                                    readonly property string subText: festText !== "" ? festText
                                        : (termText !== "" ? termText : lunarText)

                                    width: calBody.width / 7
                                    height: 32

                                    Rectangle {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.top: parent.top
                                        width: 19
                                        height: 17
                                        radius: 8.5
                                        color: cell.isToday ? Theme.magic : "transparent"
                                        visible: cell.day > 0
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.top: parent.top
                                        anchors.topMargin: 1
                                        visible: cell.day > 0
                                        text: cell.day
                                        color: cell.isToday ? Theme.wsActiveText : Theme.clockText
                                        font.family: Theme.fontFamily
                                        font.pixelSize: Theme.fontSize - 3
                                        font.weight: cell.isToday ? Theme.fontWeight : Font.Normal
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.bottom: parent.bottom
                                        anchors.bottomMargin: 0
                                        width: parent.width
                                        horizontalAlignment: Text.AlignHCenter
                                        elide: Text.ElideRight
                                        visible: cell.day > 0 && cell.subText !== ""
                                        text: cell.subText
                                        color: cell.festText !== "" ? Theme.notifyUnread
                                             : (cell.termText !== "" ? Theme.magic : Theme.panelMuted)
                                        font.family: Theme.fontFamily
                                        font.pixelSize: 7
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ══ 秒表页 ══
            Column {
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -12
                spacing: 14
                visible: root.page === 1

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Timers.fmtMs(Timers.swDisplay)
                    color: Theme.clockText
                    font.family: Theme.fontFamily
                    font.pixelSize: 30
                    font.weight: Theme.fontWeight
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8

                    PanelButton {
                        width: 72
                        text: Timers.swRunning ? "暂停" : "开始"
                        accent: Timers.swRunning ? Theme.brightness : Theme.network
                        onClicked: Timers.swToggle()
                    }
                    PanelButton {
                        width: 72
                        text: "计次"
                        accent: Theme.audio
                        armed: Timers.swRunning
                        onClicked: Timers.swLap()
                    }
                    PanelButton {
                        width: 60
                        text: "归零"
                        accent: Theme.panelMuted
                        onClicked: Timers.swReset()
                    }
                }

                // 计次列表（最近 4 条）
                Column {
                    width: parent.width
                    spacing: 2
                    visible: Timers.swLaps.length > 0

                    Repeater {
                        model: Timers.swLaps.slice(-4).reverse()
                        delegate: Text {
                            required property var modelData
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            text: Timers.fmtMs(modelData)
                            color: Theme.panelMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 3
                        }
                    }
                }
            }

            // ══ 定时器页 ══
            Column {
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -12
                spacing: 10
                visible: root.page === 2

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Timers.tmText
                    color: Timers.tmRinging ? Theme.notifyUnread : Theme.clockText
                    font.family: Theme.fontFamily
                    font.pixelSize: 30
                    font.weight: Theme.fontWeight
                }

                // 预设
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 5
                    visible: !Timers.tmRinging

                    Repeater {
                        model: [1, 5, 10, 30, 60]
                        delegate: PanelButton {
                            required property var modelData
                            width: 40
                            text: modelData + "分"
                            accent: Timers.tmTotal === modelData * 60 ? Theme.audio : Theme.panelMuted
                            onClicked: Timers.tmSetMinutes(modelData)
                        }
                    }
                }

                // 自定义（分钟）
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 6
                    visible: !Timers.tmRinging

                    Rectangle {
                        width: 62
                        height: 24
                        radius: 7
                        color: Qt.rgba(1, 1, 1, 0.07)

                        TextInput {
                            id: tmInput
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            anchors.rightMargin: 8
                            verticalAlignment: TextInput.AlignVCenter
                            color: Theme.panelText
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 2
                            selectByMouse: true
                            validator: IntValidator { bottom: 1; top: 999 }
                            onTextChanged: Timers.tmCustom = text
                            Keys.onReturnPressed: Timers.applyCustom()

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: parent.text.length === 0
                                text: "分钟"
                                color: Theme.panelMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 3
                            }
                        }
                    }

                    PanelButton {
                        width: 48
                        text: "设定"
                        accent: Theme.audio
                        onClicked: Timers.applyCustom()
                    }
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    visible: !Timers.tmRinging

                    PanelButton {
                        width: 72
                        text: Timers.tmRunning ? "暂停" : "开始"
                        accent: Timers.tmRunning ? Theme.brightness : Theme.network
                        onClicked: Timers.tmRunning ? Timers.tmPause() : Timers.tmStart()
                    }
                    PanelButton {
                        width: 72
                        text: "重置"
                        accent: Theme.panelMuted
                        onClicked: Timers.tmReset()
                    }
                }

                // 到点：关闭响亮
                PanelButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 140
                    height: 30
                    visible: Timers.tmRinging
                    text: "关闭响铃"
                    accent: Theme.notifyUnread
                    onClicked: Timers.tmDismiss()
                }
            }

            // ══ 闹钟页（多闹钟，分页切换） ══
            Column {
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -12
                spacing: 8
                visible: root.page === 3

                // 闹钟选择：‹ 1/2 ›
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 10

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "‹"
                        color: Timers.alIndex > 0 ? Theme.panelMuted : Qt.rgba(1,1,1,0.15)
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 2
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            enabled: Timers.alIndex > 0
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Timers.alIndex--
                        }
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: (Timers.alIndex + 1) + " / " + Timers.alCount
                        color: Theme.panelMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 3
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "›"
                        color: Timers.alIndex < Timers.alCount - 1 ? Theme.panelMuted : Qt.rgba(1,1,1,0.15)
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 2
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -6
                            enabled: Timers.alIndex < Timers.alCount - 1
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Timers.alIndex++
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Timers.alText
                    color: Timers.alRinging ? Theme.notifyUnread
                         : (Timers.alEnabled ? Theme.audio : Theme.clockText)
                    font.family: Theme.fontFamily
                    font.pixelSize: 30
                    font.weight: Theme.fontWeight
                }

                // 时 / 分 分开控制
                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 5
                    visible: !Timers.alRinging

                    // 时：±12h / ±1h
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 4

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 18
                            horizontalAlignment: Text.AlignRight
                            text: "时"
                            color: Theme.panelMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 3
                        }
                        PanelButton { width: 40; text: "−12"; onClicked: Timers.alAddMinutes(-720) }
                        PanelButton { width: 32; text: "−"; onClicked: Timers.alAddMinutes(-60) }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 26
                            horizontalAlignment: Text.AlignHCenter
                            text: (Timers.alHour < 10 ? "0" : "") + Timers.alHour
                            color: Theme.clockText
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.weight: Theme.fontWeight
                        }
                        PanelButton { width: 32; text: "+"; onClicked: Timers.alAddMinutes(60) }
                        PanelButton { width: 40; text: "+12"; onClicked: Timers.alAddMinutes(720) }
                    }

                    // 分：±10 / ±1
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 4

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 18
                            horizontalAlignment: Text.AlignRight
                            text: "分"
                            color: Theme.panelMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 3
                        }
                        PanelButton { width: 40; text: "−10"; onClicked: Timers.alAddMinutes(-10) }
                        PanelButton { width: 32; text: "−"; onClicked: Timers.alAddMinutes(-1) }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 26
                            horizontalAlignment: Text.AlignHCenter
                            text: (Timers.alMinute < 10 ? "0" : "") + Timers.alMinute
                            color: Theme.clockText
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.weight: Theme.fontWeight
                        }
                        PanelButton { width: 32; text: "+"; onClicked: Timers.alAddMinutes(1) }
                        PanelButton { width: 40; text: "+10"; onClicked: Timers.alAddMinutes(10) }
                    }

                    PanelButton {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 150
                        text: Timers.alEnabled ? "取消此闹钟" : "启用此闹钟"
                        accent: Timers.alEnabled ? Theme.brightness : Theme.network
                        onClicked: Timers.alEnabled ? Timers.alDisarm() : Timers.alArm()
                    }

                    // 新增 / 删除
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 6

                        PanelButton {
                            width: 74
                            text: "＋新增"
                            accent: Theme.audio
                            onClicked: Timers.alAddNew()
                        }
                        PanelButton {
                            width: 74
                            text: "－删除"
                            accent: Theme.notifyUnread
                            armed: Timers.alCount > 1
                            onClicked: Timers.alRemove(Timers.alIndex)
                        }
                    }
                }

                // 闹铃响起：关闭 / 稍后
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8
                    visible: Timers.alRinging

                    PanelButton {
                        width: 90
                        height: 30
                        text: "关闭"
                        accent: Theme.notifyUnread
                        onClicked: Timers.alDismiss()
                    }
                    PanelButton {
                        width: 90
                        height: 30
                        text: "+5 分钟"
                        accent: Theme.audio
                        onClicked: Timers.alSnooze()
                    }
                }
            }

            // ══ 底部翻页栏 ══
            Row {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 7
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 12

                Repeater {
                    model: ["日历", "秒表", "定时器", "闹钟"]
                    delegate: Text {
                        required property var modelData
                        required property int index
                        text: modelData
                        color: root.page === index ? Theme.magic : Theme.panelMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 3
                        font.weight: root.page === index ? Theme.fontWeight : Font.Normal

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -4
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.page = index
                        }
                    }
                }
            }
        }
    }
}
