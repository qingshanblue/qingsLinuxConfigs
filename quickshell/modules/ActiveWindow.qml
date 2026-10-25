// 当前焦点窗口标题：限制最大像素宽度，超出则整段往返滚动（右缘硬裁剪，由药丸 clip 裁掉）。
// 点击等效于 Super+Tab「回跳」：跳到最近聚焦的、非特殊工作区的其他窗口。
// 实现与 hyprland.lua 的 Super+Tab 一致：扫全部窗口，排除当前窗口与特殊工作区，
// 按 focusHistoryID 升序（0 = 最近聚焦）取第一个，先切到它的工作区再聚焦该窗口。
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import qs

Item {
    id: root

    // 启动兜底标题。
    // 坑：quickshell 启动时若尚未收到 Hyprland 的 activewindow 事件，
    //     Hyprland.activeToplevel 就是 null（实测：重启面板后标题一直空白，
    //     必须切一次窗口才恢复）。这里在启动时主动查一次，作为回退值。
    property string startupTitle: ""
    property var titleBuf: []

    Process {
        id: titleProbe
        command: ["hyprctl", "-j", "activewindow"]
        stdout: SplitParser { onRead: line => root.titleBuf.push(line) }
        onExited: {
            const t = root.titleBuf.join("");
            root.titleBuf = [];
            try { root.startupTitle = (JSON.parse(t).title ?? ""); } catch (e) { }
        }
    }

    Component.onCompleted: titleProbe.running = true

    readonly property string fullTitle: Hyprland.activeToplevel?.title ?? root.startupTitle
    // 最大像素宽度：由 Bar 按屏幕宽度传入，保证左右药丸之间留有空间
    property int maxWidth: 320

    // ── 宽度策略（不再估算字符宽度） ─────────────────────────────
    // 旧实现用「中文字宽 = fontSize、英文 = 0.55*fontSize」估算 naturalWidth，
    // 但 Maple Mono 是等宽字体，实际字宽与估算不符，估算偏小时
    // clipBox 也偏小 → 真正的 Text 按自然宽度渲染后被 clip 截断，
    // 表现为「文字超出药丸右侧、被硬切一半」。
    // 现在改为：让 Text 自己测量，宽度 = 真实 advanceWidth，并交给 elide 处理。
    readonly property real naturalWidth: measure.advanceWidth
    // 文本可见宽度 = min(自然宽, 上限)。
    readonly property real displayWidth: Math.min(root.naturalWidth, root.maxWidth)
    // 标题右侧留白：不让人字/省略号贴到药丸描边上（Pill 只在左侧有 pillPadding）。
    readonly property int rightPadding: 2
    readonly property bool needsScroll: root.naturalWidth > root.maxWidth + 0.5

    // 真实文本度量（非估算），只在文本/字体变化时重算
    TextMetrics {
        id: measure
        font: label.font
        text: root.fullTitle
    }

    // 行高基准：只取字体自身度量（参考串固定），不跟随标题内容。
    // 重要：若用 label.implicitHeight，标题里的 emoji（如 Telegram 标题的 🌳❓）会触发
    // fallback 字体、字高变大，Row 变高；Row 是【顶端对齐】子项并整体 verticalCenter
    // 锚在药丸上，于是行一高，整个左区（时钟/工作区/标题）全体上移。
    TextMetrics {
        id: lineMetrics
        font: label.font
        text: "Ag"
    }
    readonly property real lineHeight: Math.ceil(lineMetrics.height)

    // 参考文本（不可见）：只用来确定「标准行」的基线位置。
    // 坑：把行盒用 verticalAlignment 居中是不够的——emoji 走 fallback 字体，行盒变高后
    //     汉字/拉丁部分会被顶上去（表现为「窗口标题自己上浮」）。
    //     正确做法是【钉死基线】：基准行盒在行高内居中，基线落在 baselineY，
    //     实际标题再用「baselineY - label.baselineOffset」定位，
    //     这样含 emoji 的标题其基线也落在同一位置。
    Text {
        id: refText
        visible: false
        text: "Ag"
        font: label.font
    }
    readonly property real baselineY: Math.round((root.lineHeight - refText.implicitHeight) / 2 + refText.baselineOffset)

    property real scrollOffset: 0
    // 可滚动距离 = 完整文本宽 - 可见宽
    readonly property real scrollDistance: Math.max(0, root.naturalWidth - root.displayWidth)

    // 需要滚动时先停留再往返
    SequentialAnimation {
        running: root.needsScroll
        loops: Animation.Infinite
        onStopped: root.scrollOffset = 0

        PauseAnimation { duration: 1500 }
        NumberAnimation {
            target: root
            property: "scrollOffset"
            to: root.scrollDistance
            duration: Math.max(2000, root.scrollDistance * 45)
            easing.type: Easing.Linear
        }
        PauseAnimation { duration: 1000 }
        NumberAnimation {
            target: root
            property: "scrollOffset"
            to: 0
            duration: Math.max(2000, root.scrollDistance * 45)
            easing.type: Easing.Linear
        }
    }

    // 交给 Row 的宽度：文本宽 + 右侧留白
    implicitWidth: clipBox.width + root.rightPadding
    // 交给 Row 的高度：固定行高（不随标题内容/字体回退变化），保证整行位置稳定
    implicitHeight: root.lineHeight
    visible: fullTitle.length > 0

    // 裁剪容器：只露出 displayWidth 宽的窗口，内部整段文本靠 x 位移滚动。
    // 右缘不做渐隐：试过两种方案均不可行——
    //   ① MultiEffect 遮罩：源必须可见才有纹理，让原件不可见/移出裁区都会得到空白（标题整段消失）；
    //   ② 渐变矩形盖一层药丸底色：叠在 0.75 透明度的药丸上会明显变深，形成深色直边条。
    // 药丸已加 clip，硬裁剪就在药丸内沿，不会溢出。
    Item {
        id: clipBox
        width: root.displayWidth
        height: root.lineHeight
        clip: true

        // 滚动载体：整段文本宽度 = 完整自然宽度，靠 x 位移滚进可视窗口
        Item {
            id: scroller
            width: Math.max(root.displayWidth, root.naturalWidth)
            height: clipBox.height
            x: root.needsScroll ? -Math.min(root.scrollOffset, root.scrollDistance) : 0

            Text {
                id: label
                width: scroller.width
                // 基线钉死（不用 height + AlignVCenter）：
                // emoji 会抬高行盒，居中行盒会让汉字/拉丁部分随之上浮。
                y: root.baselineY - label.baselineOffset
                elide: Text.ElideNone
                wrapMode: Text.NoWrap
                text: root.fullTitle
                color: root.hovered ? Theme.magic : Theme.windowTitle
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                font.weight: Theme.fontWeight
            }
        }
    }



    property bool hovered: false

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: root.jumpToRecent()
    }

    // ── 回跳 ──
    property var clients: []

    // 当前活跃窗口地址（与 hyprctl clients 同源，避免 QML 侧 address 格式不一致）
    property string activeAddr: ""

    Process {
        id: activeProc
        command: ["hyprctl", "-j", "activewindow"]
        stdout: SplitParser { onRead: line => activeBuf.push(line) }
        onExited: {
            const t = activeBuf.join("");
            activeBuf = [];
            try { root.activeAddr = (JSON.parse(t).address ?? "").toLowerCase(); }
            catch (e) { root.activeAddr = ""; }
            // 拿到活跃窗口后再列全部窗口
            root.clients = [];
            listProc.running = true;
        }
    }

    property var activeBuf: []

    Process {
        id: listProc
        command: ["hyprctl", "-j", "clients"]
        stdout: SplitParser { onRead: line => root.clients.push(line) }
        onExited: {
            const text = root.clients.join("");
            root.clients = [];
            let list = [];
            try { list = JSON.parse(text); } catch (e) { return; }

            const curAddr = (root.activeAddr ?? "").toLowerCase();
            let best = null;
            let bestId = null;
            for (let i = 0; i < list.length; i++) {
                const w = list[i];
                const ws = w.workspace ?? {};
                const wsName = ws.name ?? "";
                // 跳过特殊工作区
                if (wsName.indexOf("special") === 0 || (ws.id ?? 0) < 0) continue;
                // 跳过当前窗口
                if (curAddr !== "" && (w.address ?? "").toLowerCase() === curAddr) continue;
                const id = w.focusHistoryID;
                if (id === undefined || id === null || id < 0) continue;
                if (bestId === null || id < bestId) { best = w; bestId = id; }
            }
            if (best === null) return;

            // 先切工作区（字符串形式，适配本机 Lua 派发），再聚焦窗口
            jumpQueue = [
                'hl.dsp.focus({workspace="' + best.workspace.id + '"})',
                'hl.dsp.focus({window="address:' + best.address + '"})'
            ];
            runJump();
        }
    }

    property var jumpQueue: []

    function jumpToRecent() {
        if (activeProc.running || listProc.running) return;
        root.activeBuf = [];
        activeProc.running = true;
    }

    Process {
        id: jumpProc
    }

    function runJump() {
        if (root.jumpQueue.length === 0) return;
        const cmd = root.jumpQueue.shift();
        jumpProc.command = ["hyprctl", "dispatch", cmd];
        jumpProc.running = true;
        // 上一条完成后（onExited 触发）再执行下一条，保证顺序
    }

    Connections {
        target: jumpProc
        function onExited() { root.runJump(); }
    }
}
