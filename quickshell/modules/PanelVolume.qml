// 面板 · 音量
//   顶部：音量条（跟随系统默认输出，或临时指定的某台设备，不改变系统默认）
//   中部：输出/输入 设备列表（点击设备名=临时调节该设备；右侧按钮=设为系统默认）
//   下部：应用音量混合器（每个应用独立音量/静音/切换输出或输入设备）
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs

Column {
    id: root

    // ── 基础数据 ──
    readonly property var allNodes: (Pipewire.nodes.values ?? [])

    // 输出设备 / 输入设备（排除流节点）
    readonly property var sinks: root.allNodes.filter(n => n.isSink && !n.isStream && n.audio)
    readonly property var sources: root.allNodes.filter(n => !n.isSink && !n.isStream && n.audio)

    // 应用流：按 media.class 区分输入/输出
    function mediaClass(n) {
        return (n.properties ?? {})["media.class"] ?? "";
    }
    readonly property var allStreams: root.allNodes.filter(n => n.isStream && n.audio)
    readonly property var streams: root.allStreams.filter(n => root.mediaClass(n).indexOf("Stream/Input") !== 0)
    readonly property var inputStreams: root.allStreams.filter(n => root.mediaClass(n).indexOf("Stream/Input") === 0)

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    property bool showInputs: false

    // 音量条目标设备：null = 跟随系统默认（输出页跟 sink，输入页跟 source）
    property var outTarget: null
    property var inTarget: null

    readonly property var activeDevice: root.showInputs
        ? (root.inTarget ?? root.source)
        : (root.outTarget ?? root.sink)
    readonly property bool muted: root.activeDevice?.audio?.muted ?? false
    readonly property real volume: root.activeDevice?.audio?.volume ?? 0
    readonly property int percent: Math.round(root.volume * 100)

    function resetTarget() {
        root.outTarget = null;
        root.inTarget = null;
    }

    // 切页/打开面板后短暂禁用回写，避免布局重排时滑块误触发
    property bool writeLocked: false
    onShowInputsChanged: {
        root.writeLocked = true;
        unlockTimer.restart();
    }
    Timer {
        id: unlockTimer
        interval: 250
        running: false
        onTriggered: root.writeLocked = false
    }

    // 流 node.name -> 当前连接的目标设备名
    property var linkMap: ({})

    spacing: 8

    // 跟踪所有节点（不依赖派生属性，避免绑定循环）
    PwObjectTracker {
        objects: (Pipewire.nodes.values ?? []).slice()
    }

    // 应用显示名
    function streamAppName(n) {
        const pr = n.properties ?? {};
        const direct = pr["application.name"] ?? "";
        const bracket = direct.match(/\[(.+?)\]/);
        if (bracket) return bracket[1];
        if (direct !== "") return direct;
        const nm = n.name ?? "";
        const dot = nm.lastIndexOf(".");
        if (dot >= 0 && dot < nm.length - 1) return nm.slice(dot + 1);
        return "未知应用";
    }

    // 设备友好名
    function deviceLabel(nodeName) {
        if (!nodeName) return "未知设备";
        for (let i = 0; i < root.allNodes.length; i++) {
            if (root.allNodes[i].name === nodeName)
                return root.allNodes[i].description || nodeName;
        }
        return nodeName;
    }

    // 重启 PipeWire 服务栈（与 systemctl --user restart pipewire pipewire-pulse wireplumber 等价）
    function resetAudio() {
        resetProc.command = ["systemctl", "--user", "restart", "pipewire", "pipewire-pulse", "wireplumber"];
        resetProc.running = true;
    }

    Process {
        id: resetProc
    }

    // ── 解析 pw-link -l：得到 流节点 -> 对端设备 ──
    property var linkLines: []

    Process {
        id: scanLinks
        running: true
        command: ["pw-link", "-l"]
        stdout: SplitParser { onRead: line => root.linkLines.push(line) }
        onExited: {
            const lines = root.linkLines.slice();
            root.linkLines = [];
            const map = {};
            let cur = "";
            let kind = "";
            for (let i = 0; i < lines.length; i++) {
                const raw = lines[i];
                const line = raw.replace(/\s+$/, "");
                if (line === "") continue;

                // 子行（以空白开头）是链接描述
                if (line.charAt(0) === " " || line.charAt(0) === "\t") {
                    const lk = line.match(/^\s*\|(->|<-)\s+(.+)$/);
                    if (!lk || cur === "") continue;
                    const peer = lk[2].split("\t")[0].trim();
                    const node = peer.lastIndexOf(":") >= 0
                        ? peer.slice(0, peer.lastIndexOf(":"))
                        : peer;
                    if (kind === "output" && lk[1] === "->") map[cur] = node;
                    if (kind === "input" && lk[1] === "<-") map[cur] = node;
                    continue;
                }

                // 块头：节点名可能含空格，端口名形如 output_MONO / input_FL
                const head = line.match(/^(.+):((?:output|input)_[A-Za-z0-9]+)$/);
                if (head) {
                    cur = head[1];
                    kind = head[2].split("_")[0];
                } else {
                    cur = "";
                }
            }
            root.linkMap = map;
        }
    }

    // ── 音量条标题行：用锚定布局，避免固定宽度计算把右侧开关挤出面板 ──
    Item {
        width: parent.width
        // 高度取最高的子元素，避免按钮上下被裁切
        height: Math.max(24, muteToggle.implicitHeight, resetBtn.implicitHeight)

        Text {
            id: volLabel
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: {
                const base = root.showInputs ? "麦克风" : "音量";
                return root.muted ? base + " · 已静音" : base;
            }
            color: Theme.audio
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
        }

        // 静音开关贴右
        PanelToggle {
            id: muteToggle
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            checked: !root.muted          // 打开 = 有声音
            enabledState: !!root.activeDevice
            onToggled: v => {
                if (root.activeDevice?.audio) root.activeDevice.audio.muted = !v;
            }
        }

        // 重置按钮：静音开关左侧 14px
        PanelButton {
            id: resetBtn
            width: 56
            anchors.right: muteToggle.left
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            text: "重置"
            accent: Theme.brightness
            onClicked: root.resetAudio()
        }
    }

    Row {
        width: parent.width
        spacing: Theme.spacing

        PanelSlider {
            width: parent.width - pct.width - Theme.spacing
            anchors.verticalCenter: parent.verticalCenter
            value: root.volume
            onMoved: v => {
                if (root.writeLocked) return;
                if (root.activeDevice?.audio) root.activeDevice.audio.volume = v;
            }
        }

        Text {
            id: pct
            text: root.percent + "%"
            color: Theme.audio
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
        }
    }

    // ── 设备切换按钮 ──
    Row {
        width: parent.width
        spacing: 8

        PanelButton {
            text: "输出设备"
            accent: root.showInputs ? Theme.panelMuted : Theme.audio
            onClicked: root.showInputs = false
        }

        PanelButton {
            text: "输入设备"
            accent: root.showInputs ? Theme.audio : Theme.panelMuted
            onClicked: root.showInputs = true
        }
    }

    // ── 设备列表 ──
    Column {
        width: parent.width
        spacing: 3

        Repeater {
            model: root.showInputs ? root.sources : root.sinks

            delegate: Row {
                id: devRow
                required property var modelData
                width: root.width
                spacing: 6

                readonly property bool isSystemDefault: root.showInputs
                    ? (root.source === devRow.modelData)
                    : (root.sink === devRow.modelData)
                // 当前音量条指向的设备
                readonly property var curTarget: root.showInputs ? root.inTarget : root.outTarget
                readonly property bool isSliderTarget: devRow.curTarget === null
                    ? devRow.isSystemDefault
                    : (devRow.curTarget === devRow.modelData)

                // 设备名：点击切换音量条目标
                Text {
                    width: parent.width - 56
                    elide: Text.ElideRight
                    anchors.verticalCenter: parent.verticalCenter
                    text: (devRow.isSliderTarget ? "● " : "○ ")
                        + (devRow.modelData.description || devRow.modelData.name || "未知设备")
                    color: devRow.isSliderTarget ? Theme.audio : Theme.panelText
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                    font.weight: Theme.fontWeight

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // 点当前目标 → 恢复跟随系统默认
                            if (root.showInputs)
                                root.inTarget = devRow.isSliderTarget ? null : devRow.modelData;
                            else
                                root.outTarget = devRow.isSliderTarget ? null : devRow.modelData;
                        }
                    }
                }

                PanelButton {
                    width: 52
                    text: devRow.isSystemDefault ? "当前" : "切换"
                    accent: devRow.isSystemDefault ? Theme.panelMuted : Theme.network
                    armed: !devRow.isSystemDefault
                    onClicked: {
                        if (root.showInputs)
                            Pipewire.preferredDefaultAudioSource = devRow.modelData;
                        else
                            Pipewire.preferredDefaultAudioSink = devRow.modelData;
                    }
                }
            }
        }
    }

    // ── 应用音量混合器（仅输出页） ──
    Rectangle {
        width: parent.width
        height: 1
        color: Theme.panelDivider
        visible: !root.showInputs && root.streams.length > 0
    }

    Text {
        visible: !root.showInputs && root.streams.length > 0
        text: "应用音量"
        color: Theme.panelMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
        font.weight: Theme.fontWeight
    }

    Column {
        width: parent.width
        spacing: 10
        visible: !root.showInputs

        Repeater {
            model: root.streams

            delegate: Column {
                id: streamRow
                required property var modelData
                width: root.width
                spacing: 4

                readonly property real vol: streamRow.modelData.audio?.volume ?? 0
                readonly property bool mute: streamRow.modelData.audio?.muted ?? false
                property bool showTargets: false

                Row {
                    width: parent.width
                    spacing: 6

                    Text {
                        width: parent.width - muteBtn.width - 6
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                        text: (streamRow.mute ? "󰝟 " : "󰕾 ") + root.streamAppName(streamRow.modelData)
                            + "  " + Math.round(streamRow.vol * 100) + "%"
                        color: streamRow.mute ? Theme.panelMuted : Theme.windowTitle
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                        font.weight: Theme.fontWeight
                    }

                    PanelButton {
                        id: muteBtn
                        width: 44
                        text: streamRow.mute ? "解除" : "静音"
                        accent: streamRow.mute ? Theme.panelMuted : Theme.audio
                        onClicked: {
                            if (streamRow.modelData.audio)
                                streamRow.modelData.audio.muted = !streamRow.modelData.audio.muted;
                        }
                    }
                }

                // 仅当应用输出设备与系统默认不同时，才提示当前所在设备
                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    readonly property string curDev: root.linkMap[streamRow.modelData.name] ?? ""
                    readonly property string sysDev: root.sink?.name ?? ""
                    visible: curDev !== "" && curDev !== sysDev
                    text: "→ " + root.deviceLabel(curDev)
                    color: Theme.panelMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 3
                    font.weight: Theme.fontWeight
                }

                PanelSlider {
                    width: parent.width
                    value: streamRow.vol
                    accent: Theme.audio
                    onMoved: v => {
                        if (streamRow.modelData.audio) streamRow.modelData.audio.volume = v;
                    }
                }

                PanelButton {
                    text: streamRow.showTargets ? "收起" : "切换输出设备"
                    accent: Theme.panelMuted
                    onClicked: streamRow.showTargets = !streamRow.showTargets
                }

                Column {
                    width: parent.width
                    spacing: 2
                    visible: streamRow.showTargets

                    Repeater {
                        model: root.sinks

                        delegate: Row {
                            id: targetRow
                            required property var modelData
                            width: root.width
                            spacing: 6

                            // 该应用当前所在的设备
                            readonly property bool isCurrent:
                                root.linkMap[streamRow.modelData.name] === targetRow.modelData.name

                            Text {
                                width: parent.width - 56
                                elide: Text.ElideRight
                                anchors.verticalCenter: parent.verticalCenter
                                text: (targetRow.isCurrent ? "● " : "○ ")
                                    + (targetRow.modelData.description || targetRow.modelData.name || "设备")
                                color: targetRow.isCurrent ? Theme.audio : Theme.panelText
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 3
                                font.weight: Theme.fontWeight
                            }

                            PanelButton {
                                width: 52
                                text: targetRow.isCurrent ? "当前" : "切换"
                                accent: targetRow.isCurrent ? Theme.panelMuted : Theme.network
                                armed: !targetRow.isCurrent
                                onClicked: root.moveStream(streamRow.modelData.name, targetRow.modelData.name, false)
                            }
                        }
                    }
                }
            }
        }
    }

    // ── 应用输入设备切换 ──
    Rectangle {
        width: parent.width
        height: 1
        color: Theme.panelDivider
        visible: root.showInputs && root.inputStreams.length > 0
    }

    Text {
        visible: root.showInputs && root.inputStreams.length > 0
        text: "应用麦克风"
        color: Theme.panelMuted
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize - 2
        font.weight: Theme.fontWeight
    }

    Column {
        width: parent.width
        spacing: 10
        visible: root.showInputs

        Repeater {
            model: root.inputStreams

            delegate: Column {
                id: inRow
                required property var modelData
                width: root.width
                spacing: 4

                property bool showTargets: false

                readonly property real inVol: inRow.modelData.audio?.volume ?? 0
                readonly property bool inMute: inRow.modelData.audio?.muted ?? false

                Row {
                    width: parent.width
                    spacing: 6

                    Text {
                        width: parent.width - inMuteBtn.width - 6
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                        text: (inRow.inMute ? "󰍬 " : "󰍬 ") + root.streamAppName(inRow.modelData)
                            + "  " + Math.round(inRow.inVol * 100) + "%"
                        color: inRow.inMute ? Theme.panelMuted : Theme.windowTitle
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize - 2
                        font.weight: Theme.fontWeight
                    }

                    PanelButton {
                        id: inMuteBtn
                        width: 44
                        text: inRow.inMute ? "解除" : "静音"
                        accent: inRow.inMute ? Theme.panelMuted : Theme.audio
                        onClicked: {
                            if (inRow.modelData.audio)
                                inRow.modelData.audio.muted = !inRow.modelData.audio.muted;
                        }
                    }
                }

                // 输入音量滑块
                PanelSlider {
                    width: parent.width
                    value: inRow.inVol
                    accent: Theme.audio
                    onMoved: v => {
                        if (inRow.modelData.audio) inRow.modelData.audio.volume = v;
                    }
                }

                Text {
                    width: parent.width
                    elide: Text.ElideRight
                    readonly property string curDev: root.linkMap[inRow.modelData.name] ?? ""
                    readonly property string sysDev: root.source?.name ?? ""
                    visible: curDev !== "" && curDev !== sysDev
                    text: "← " + root.deviceLabel(curDev)
                    color: Theme.panelMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 3
                    font.weight: Theme.fontWeight
                }

                PanelButton {
                    text: inRow.showTargets ? "收起" : "切换输入设备"
                    accent: Theme.panelMuted
                    onClicked: inRow.showTargets = !inRow.showTargets
                }

                Column {
                    width: parent.width
                    spacing: 2
                    visible: inRow.showTargets

                    Repeater {
                        model: root.sources

                        delegate: Row {
                            id: srcRow
                            required property var modelData
                            width: root.width
                            spacing: 6

                            readonly property bool isCurrent:
                                root.linkMap[inRow.modelData.name] === srcRow.modelData.name

                            Text {
                                width: parent.width - 56
                                elide: Text.ElideRight
                                anchors.verticalCenter: parent.verticalCenter
                                text: (srcRow.isCurrent ? "● " : "○ ")
                                    + (srcRow.modelData.description || srcRow.modelData.name || "设备")
                                color: srcRow.isCurrent ? Theme.audio : Theme.panelText
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 3
                                font.weight: Theme.fontWeight
                            }

                            PanelButton {
                                width: 52
                                text: srcRow.isCurrent ? "当前" : "切换"
                                accent: srcRow.isCurrent ? Theme.panelMuted : Theme.network
                                armed: !srcRow.isCurrent
                                onClicked: root.moveStream(inRow.modelData.name, srcRow.modelData.name, true)
                            }
                        }
                    }
                }
            }
        }
    }

    // ── 重连：用 pw-link 断开旧连接并连到目标 ──
    property string pendingStream: ""
    property string pendingTarget: ""
    property bool pendingIsInput: false
    property var dumpLines: []

    function moveStream(streamName, targetName, isInput) {
        if (!streamName || !targetName) return;
        root.pendingStream = streamName;
        root.pendingTarget = targetName;
        root.pendingIsInput = isInput;
        root.dumpLines = [];
        dumpCmd.command = ["pw-link", "-l"];
        dumpCmd.running = true;
    }

    Process {
        id: dumpCmd
        stdout: SplitParser { onRead: line => root.dumpLines.push(line) }
        onExited: {
            const lines = root.dumpLines.slice();
            const stream = root.pendingStream;
            const target = root.pendingTarget;
            const isInput = root.pendingIsInput;
            root.dumpLines = [];
            if (!stream || !target) return;

            // 找到该流端口的旧连接
            const olds = [];
            let cur = "";
            let kind = "";
            for (let i = 0; i < lines.length; i++) {
                const head = lines[i].match(/^([^ |]+):(output|input)_(\S+)\s*$/);
                if (head) { cur = head[1]; kind = head[2]; continue; }
                const lk = lines[i].match(/^\s*\|(->|<-)\s+(\S+?):(\S+)\s*$/);
                if (!lk || cur !== stream) continue;
                if (kind === "output" && lk[1] === "->") olds.push([cur, lk[2] + ":" + lk[3], head]);
                if (kind === "input" && lk[1] === "<-") olds.push([cur, lk[2] + ":" + lk[3], head]);
            }

            const cmds = [];
            // 断开旧连接（端口名需完整，这里重新扫一遍端口后缀）
            const portInfo = [];
            cur = ""; kind = "";
            for (let i = 0; i < lines.length; i++) {
                const head = lines[i].match(/^([^ |]+):((?:output|input)_\S+)\s*$/);
                if (head) { cur = head[1]; kind = head[2]; continue; }
                const lk = lines[i].match(/^\s*\|(->|<-)\s+(\S+?):(\S+)\s*$/);
                if (!lk || cur !== stream) continue;
                portInfo.push({ node: cur, port: kind, peer: lk[2] + ":" + lk[3] });
            }

            for (let i = 0; i < portInfo.length; i++) {
                const p = portInfo[i];
                const suffix = p.port.split("_").slice(1).join("_");   // MONO / FL / FR
                const targetPort = (isInput ? "capture_" : "playback_") + suffix;
                cmds.push("pw-link -d '" + p.node + ":" + p.port + "' '" + p.peer + "'");
                cmds.push("pw-link '" + p.node + ":" + p.port + "' '" + target + ":" + targetPort + "'");
            }

            if (cmds.length === 0) return;
            relink.command = ["sh", "-c", cmds.join("; ")];
            relink.running = true;
            root.pendingStream = "";
            root.pendingTarget = "";
        }
    }

    Process {
        id: relink
        onExited: {
            // 切完重新扫描设备归属
            scanLinks.running = false;
            scanLinks.running = true;
        }
    }
}
