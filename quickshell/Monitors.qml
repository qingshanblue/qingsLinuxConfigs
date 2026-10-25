// 各显示器的当前工作区（事件驱动）
// 原因：HyprlandMonitor.lastIpcObject 是快照对象，其属性变化不会触发 QML 绑定更新，
// 所以直接绑定会一直停留在初始值。这里改为监听 Hyprland.rawEvent，
// 发生 workspace / focusedmon / activespecial 事件时重新读取一次 hyprctl。
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

QtObject {
    id: root

    // 显示器名 -> 当前工作区 id
    property var activeByMonitor: ({})
    // 显示器名 -> 当前特殊工作区名（不含 special: 前缀），无则为空串
    property var specialByMonitor: ({})

    // 首次就绪后主动读一次
    Component.onCompleted: refresh()

    function refresh() {
        if (!proc.running) proc.running = true;
    }

    // 监听 Hyprland 事件，只在影响工作区归属时刷新
    property Connections hyprConn: Connections {
        target: Hyprland
        function onRawEvent(event) {
            const n = (event?.name ?? "").toLowerCase();
            if (n.indexOf("workspace") === 0 || n === "focusedmon"
                || n === "activespecial" || n === "createworkspace" || n === "destroyworkspace")
                root.refresh();
        }
    }

    property var buf: []

    property Process proc: Process {
        id: proc
        command: ["hyprctl", "-j", "monitors"]
        stdout: SplitParser { onRead: line => root.buf.push(line) }
        onExited: {
            const text = root.buf.join("");
            root.buf = [];
            try {
                const list = JSON.parse(text);
                const act = {};
                const sp = {};
                for (let i = 0; i < list.length; i++) {
                    const m = list[i];
                    act[m.name] = m.activeWorkspace?.id ?? -1;
                    const sname = m.specialWorkspace?.name ?? "";
                    sp[m.name] = sname.indexOf("special:") === 0 ? sname.slice(8) : "";
                }
                root.activeByMonitor = act;
                root.specialByMonitor = sp;
            } catch (e) {
                // 解析失败时保持旧值，下次事件再试
            }
        }
    }
}
