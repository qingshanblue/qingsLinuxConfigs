// 媒体播放：中区药丸，与左右药丸同高同形。单行「歌手 · 歌名」，宽度随内容动态伸缩。
//
// 宽度约定：
//   availWidth = 中区药丸【外框】的宽度上限（Bar 传入的空隙预算，含内边距）
//   minWidth   = 仅图标时的外框宽度
//   实际外框宽 = clamp(内容自然宽 + 内边距*2, minWidth, availWidth)
//
// 三种形态（宽度自动在各形态之间伸缩）：
//   ① 文本可显示        → 「歌手 · 歌名」，无图标
//   ② 文本超出上限      → 保持最大宽度，文本往返滚动，无图标
//   ③ 正在播放但元数据未到（切歌空窗） → 仅一个播放图标，宽度收窄到 minWidth
// 若既无文本又不在播放（例如残留的 MPRIS 客户端），则整个药丸隐藏。
//
// 数据来自 Quickshell.Services.Mpris，事件驱动。
import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs

Item {
    id: root

    // 弹窗锚定窗口（由 Bar 赋值）
    property var hostWindow: null
    readonly property alias popup: mediaPanel

    // 外框宽度上限（Bar 传入）
    property int availWidth: 220
    // 仅图标时的外框宽度
    readonly property int minWidth: Theme.pillHeight + 12

    // ── 播放器列表 ──────────────────────────────────────────────
    property var playerList: []

    Connections {
        target: Mpris.players
        function onValuesChanged() { root.refreshPlayers(); }
        function onObjectInsertedPost() { root.refreshPlayers(); }
        function onObjectRemovedPost() { root.refreshPlayers(); }
    }

    function refreshPlayers() {
        const v = Mpris.players?.values;
        root.playerList = v ? Array.from(v) : [];
    }

    readonly property var player: {
        const list = root.playerList;
        for (let i = 0; i < list.length; i++)
            if (list[i].isPlaying) return list[i];
        return list.length > 0 ? list[0] : null;
    }

    readonly property string title: {
        root.playerList;
        return root.player?.trackTitle ?? "";
    }
    readonly property string artist: {
        root.playerList;
        return root.player?.trackArtist ?? "";
    }
    readonly property bool playing: {
        root.playerList;
        return root.player?.isPlaying ?? false;
    }

    // ── 是否存在媒体 ────────────────────────────────────────────
    // 注意：不能用 visible 表示，因为父 Pill 的 visible 绑定到它，
    // 父隐藏会把子也隐式设为不可见，形成互锁。
    readonly property bool mediaPresent: {
        root.playerList;
        return root.playerList.length > 0;
    }

    // 当前选中的播放器是否“真的在播放内容”：
    //   - 有标题/歌手 → 算；
    //   - 或正在播放（正在播放但元数据还没到，比如刚开播/切歌空窗）→ 算。
    // 反之（播放器壳还在但既无元数据又不在播放，如残留的 chromium/musicfox 客户端）
    // → 视为“无媒体”，整体隐藏，不再显示那个孤零零的暂停图标。
    readonly property bool playerHasContent: {
        root.playerList;
        if (root.title !== "" || root.artist !== "") return true;
        return root.playing;
    }

    property bool hasMedia: false

    Timer {
        id: settleTimer
        interval: 250
        running: false
        onTriggered: root.hasMedia = root.mediaPresent && root.playerHasContent
    }

    onMediaPresentChanged: root.resettle()
    onPlayerHasContentChanged: root.resettle()

    function resettle() {
        const want = root.mediaPresent && root.playerHasContent;
        if (want === root.hasMedia) { settleTimer.stop(); return; }
        settleTimer.restart();
    }

    Component.onCompleted: {
        root.refreshPlayers();
        root.hasMedia = root.mediaPresent && root.playerHasContent;
    }

    visible: root.hasMedia || exitFade.running
    opacity: root.hasMedia ? 1 : 0

    Behavior on opacity {
        NumberAnimation { duration: 220; easing.type: Easing.InOutQuad }
    }

    Timer {
        id: exitFade
        interval: 220
        running: !root.hasMedia
        onTriggered: {}
    }

    // ── 文本与形态 ──────────────────────────────────────────────
    readonly property string singleText: root.artist !== "" ? root.artist + " · " + root.title : root.title
    readonly property bool hasText: root.singleText !== ""

    // 文本可用宽度（外框预算扣掉内边距）
    readonly property int textBudget: Math.max(24, root.availWidth - Theme.pillPadding * 2)

    TextMetrics {
        id: textMetrics
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
        font.weight: Theme.fontWeight
        text: root.singleText
    }
    TextMetrics {
        id: iconMetrics
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 1
        text: "󰏤"
    }

    readonly property real naturalTextWidth: textMetrics.advanceWidth
    readonly property bool needScroll: root.naturalTextWidth > root.textBudget + 0.5

    // 文本态：有文本且预算能放下至少一点内容
    readonly property bool textMode: root.hasText && root.textBudget >= 60

    // 内容宽度（药丸内部，不含内边距）
    readonly property real contentNaturalWidth: root.textMode
        ? Math.min(root.naturalTextWidth, root.textBudget)
        : iconMetrics.advanceWidth

    // 药丸外框宽度：文本态取内容宽、图标态取固定最小宽
    readonly property real pillWidth: root.hasMedia
        ? (root.textMode
            ? Math.max(root.minWidth, Math.min(root.availWidth, root.contentNaturalWidth + Theme.pillPadding * 2))
            : root.minWidth)
        : 0

    implicitWidth: Math.ceil(root.pillWidth)
    implicitHeight: Theme.pillHeight

    property bool hovered: false
    // panelOpen 直接别名到动画控制器：外部照旧读写 root.panelOpen，
    // 打开/收起、出现/消失动画全由 PanelAnim 统一负责，不会有两份状态。
    property alias panelOpen: mediaPanel.anim.open

    // ── 内容：图标 + 文本，整体在药丸内上下左右居中 ─────────────
    // 文本带固定为预算宽度并裁剪，文本超出时往返滚动
    Item {
        id: clip
        anchors.centerIn: parent
        width: Math.min(root.pillWidth - Theme.pillPadding * 2, root.contentNaturalWidth)
        height: root.implicitHeight
        clip: true
        visible: root.pillWidth > 0

        Text {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(parent.width, implicitWidth)
            horizontalAlignment: Text.AlignHCenter
            text: root.textMode ? root.singleText : (root.playing ? "󰐊" : "󰏤")
            color: root.hovered ? Theme.magic : (root.textMode ? Theme.windowTitle : Theme.audio)
            font.family: Theme.fontFamily
            font.pixelSize: root.textMode ? Theme.fontSize - 2 : Theme.fontSize - 1
            font.weight: Theme.fontWeight
            x: (root.needScroll && root.textMode) ? -root.scrollOffset : 0
        }
    }

    // 宽度变化动画由外层药丸负责（见 Bar.qml），这里不再重复设置。

    // ── 往返滚动（仅文本溢出时）─────────────────────────────────
    property real scrollOffset: 0
    readonly property real scrollDistance: Math.max(0, root.naturalTextWidth - root.textBudget)

    SequentialAnimation {
        running: root.needScroll && root.textMode && !root.panelOpen
        loops: Animation.Infinite
        onStopped: root.scrollOffset = 0

        PauseAnimation { duration: 1400 }
        NumberAnimation {
            target: root
            property: "scrollOffset"
            to: root.scrollDistance
            duration: Math.max(1800, root.scrollDistance * 45)
            easing.type: Easing.Linear
        }
        PauseAnimation { duration: 1000 }
        NumberAnimation {
            target: root
            property: "scrollOffset"
            to: 0
            duration: Math.max(1800, root.scrollDistance * 45)
            easing.type: Easing.Linear
        }
    }

    // 文字内容变化时短淡入，避免换歌瞬间"突然消失又出现"
    readonly property string contentKey: root.title + "|" + root.artist
    property real contentOpacity: 1

    onContentKeyChanged: {
        contentOpacity = 0;
        contentFade.restart();
    }

    Timer {
        id: contentFade
        interval: 20
        running: false
        onTriggered: contentFadeAnim.start()
    }

    NumberAnimation {
        id: contentFadeAnim
        target: clip
        property: "opacity"
        to: 1
        duration: 180
        easing.type: Easing.OutCubic
    }
    Binding { target: clip; property: "opacity"; value: root.contentOpacity }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: root.panelOpen = !root.panelOpen
    }

    // ── 控制面板 ────────────────────────────────────────────────
    PopupWindow {
        id: mediaPanel

        // 出现/消失动画控制器：root.panelOpen 是 anim.open 的别名，外部照旧用 panelOpen；
        // 被合成器（点面板外）关闭时，PanelAnim 内部会自己把状态对齐。
        property PanelAnim anim: PanelAnim { target: mediaPanel }

        visible: anim.surfaced
        color: "transparent"
        implicitWidth: 300
        implicitHeight: panelRect.implicitHeight

        anchor.item: root.parent
        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        anchor.adjustment: PopupAdjustment.SlideX
        // 恒定 true：PopupWindow 的抓取必须与「表面创建」同一时刻生效，绑到会变化的
        // 属性上（曾写成 anim.open）会让抓取请求与表面映射竞争而被丢弃，
        // 表现为「点面板外关不掉」。抓取的存续由 visible: anim.surfaced 控制。
        grabFocus: true

        // panelOpen 已是 anim.open 的别名，无需额外同步。

        Rectangle {
            id: panelRect
            // 不用 anchors.fill：y 要参与动画，anchors 会接管 y 导致冲突，改用显式几何
            x: 0
            width: parent.width
            height: parent.height
            // 动画：从略小 / 略上 / 透明 → 正常（transformOrigin 在顶部，从药丸那一侧展开）
            opacity: mediaPanel.anim.progress
            scale: mediaPanel.anim.scaleFrom + (1 - mediaPanel.anim.scaleFrom) * mediaPanel.anim.progress
            y: mediaPanel.anim.offsetY * (1 - mediaPanel.anim.progress)
            transformOrigin: Item.Top
            radius: 10
            color: Theme.panelBg
            border.color: Theme.pillBorder
            border.width: 1
            implicitHeight: panelCol.implicitHeight + 24

            Column {
                id: panelCol
                width: parent.width - 28
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                // 头部：封面 + 标题 + 歌手，整体水平居中（垂直堆叠，居中更美观）
                Column {
                    width: parent.width
                    spacing: 8

                    // 专辑封面缩略图（无封面时显示占位图标），居中
                    Item {
                        width: 56
                        height: 56
                        anchors.horizontalCenter: parent.horizontalCenter

                        // 占位：圆角底 + 音符图标（无封面时可见）
                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: Qt.rgba(1, 1, 1, 0.06)
                            visible: !(art.status === Image.Ready)
                            Text {
                                anchors.centerIn: parent
                                text: "󰎈"
                                color: Theme.panelMuted
                                font.family: Theme.fontFamily
                                font.pixelSize: 24
                            }
                        }

                        // 封面：圆角卡片内裁剪显示（用容器 clip 实现）
                        Item {
                            anchors.fill: parent
                            clip: true

                            Image {
                                id: art
                                anchors.fill: parent
                                source: root.player?.trackArtUrl ?? ""
                                sourceSize.width: 112
                                sourceSize.height: 112
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                visible: status === Image.Ready
                            }
                        }

                        // 细描边，提升与背景的分离度
                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: "transparent"
                            border.color: Qt.rgba(1, 1, 1, 0.10)
                            border.width: 1
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: 2

                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            text: root.title !== "" ? root.title : "（无标题）"
                            color: Theme.clockText
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            font.weight: Theme.fontWeight
                        }
                        Text {
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            visible: root.artist !== ""
                            text: root.artist + (root.player?.trackAlbum ? "  ·  " + root.player.trackAlbum : "")
                            color: Theme.panelMuted
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 2
                        }
                    }
                }

                // 进度条：可点击/拖动跳转（仅播放器支持 seek 时）
                Item {
                    id: progressBar
                    width: parent.width
                    height: 5
                    enabled: root.player?.canSeek ?? false

                    readonly property real ratio: {
                        const len = root.player?.length ?? 0;
                        const pos = root.displayPosition;
                        return len > 0 ? Math.max(0, Math.min(1, pos / len)) : 0;
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: 2.5
                        color: Qt.rgba(1, 1, 1, 0.12)
                    }
                    Rectangle {
                        width: parent.width * parent.ratio
                        height: parent.height
                        radius: 2.5
                        color: Theme.audio
                    }
                    Rectangle {
                        // 拖动/悬停指示点
                        width: 9; height: 9; radius: 4.5
                        color: Theme.audio
                        visible: progressArea.containsMouse
                        x: parent.width * parent.ratio - width / 2
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    MouseArea {
                        id: progressArea
                        anchors.fill: parent
                        anchors.topMargin: -5
                        anchors.bottomMargin: -5
                        hoverEnabled: true
                        cursorShape: progressBar.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        enabled: progressBar.enabled
                        function seekTo(mx) {
                            const len = root.player?.length ?? 0;
                            if (len <= 0) return;
                            const target = Math.max(0, Math.min(1, mx / progressBar.width)) * len;
                            const cur = root.player.position;
                            root.player.seek(target - cur);
                            root.seekBasePosition = target;
                            root.seekBaseTick = root.tick;
                            root.seekBaseValid = true;
                        }
                        onPressed: mouse => seekTo(mouse.x)
                        onPositionChanged: mouse => { if (mouse.buttons & Qt.LeftButton) seekTo(mouse.x) }
                    }
                }

                // 时间标签（当前 / 总长）：左右对齐
                Item {
                    width: parent.width
                    height: 12
                    visible: (root.player?.length ?? 0) > 0

                    Text {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.formatTime(root.displayPosition)
                        color: Theme.panelMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 4
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.formatTime(root.player?.length ?? 0)
                        color: Theme.panelMuted
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 4
                    }
                }

                // 控制按钮
                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 8

                    PanelButton {
                        width: 40
                        text: "󰒮"
                        armed: root.player?.canGoPrevious ?? false
                        onClicked: if (root.player) root.player.previous()
                    }
                    PanelButton {
                        width: 54
                        text: root.playing ? "󰏤" : "󰐊"
                        accent: Theme.audio
                        onClicked: if (root.player) root.player.togglePlaying()
                    }
                    PanelButton {
                        width: 40
                        text: "󰒭"
                        armed: root.player?.canGoNext ?? false
                        onClicked: if (root.player) root.player.next()
                    }
                }
            }
        }
    }

    // ── 进度：本地计时外推 ──────────────────────────────────────
    property int tick: 0
    property real seekBasePosition: 0
    property int seekBaseTick: 0
    property bool seekBaseValid: false

    readonly property real displayPosition: {
        root.playerList;
        root.tick;
        const len = root.player?.length ?? 0;
        const raw = root.player?.position ?? 0;
        if (!root.seekBaseValid) {
            return Math.max(0, Math.min(len > 0 ? len : Math.max(raw, 1e9), raw));
        }
        const elapsed = (root.tick - root.seekBaseTick);
        let pos = root.seekBasePosition + (root.playing ? elapsed : 0);
        if (len > 0) pos = Math.min(pos, len);
        return Math.max(0, pos);
    }

    Connections {
        target: root.player
        function onPositionChanged() {
            root.seekBaseValid = false;
            root.tick++;
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.panelOpen && root.playing
        onTriggered: root.tick++
    }

    function formatTime(sec) {
        const s = Math.max(0, Math.floor(sec ?? 0));
        const m = Math.floor(s / 60);
        const r = s % 60;
        return m + ":" + (r < 10 ? "0" : "") + r;
    }
}
