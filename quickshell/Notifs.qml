pragma Singleton

// 通知服务（单例）：独占 org.freedesktop.Notifications，维护历史、勿扰、未读数与弹出卡片队列。
// 历史直接取 NotificationServer.trackedNotifications：通知被设为 tracked=true 后会一直保留，直到用户关闭或清空。
// 注意：wayle 持有同名 D-Bus 名字时，NotificationServer 注册会失败，属预期；需停掉 wayle 才能生效（由用户决定）。
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Scope {
    id: root

    // 勿扰：开启时新通知不弹卡片，但仍进入历史
    property bool dnd: false
    // 上次打开通知中心以来新到达的通知数（未读）；打开通知中心时清零
    property int unread: 0
    // 弹出卡片队列，元素为 { n: Notification, at: 到达时间戳(ms) }
    property var toasts: []

    readonly property int toastMs: 5000     // 卡片存活时长
    readonly property int maxToasts: 5      // 同屏卡片上限，超出时丢弃最旧的

    // 历史列表，最新在上。NotificationServer.trackedNotifications 是 UntypedObjectModel，values 为数组
    readonly property var history: {
        const list = server.trackedNotifications.values;
        return list ? list.slice().reverse() : [];
    }

    NotificationServer {
        id: server
        // 配置热重载时保留已注册的服务与历史，避免丢失已接收的通知
        keepOnReload: true

        onNotification: n => {
            n.tracked = true;          // 进入历史；否则通知方关闭后对象即被销毁
            root.unread += 1;
            if (!root.dnd) {
                root.pushToast(n);
                root.playSound();
            }
        }
    }

    // 通知提示音（Quickshell 无播放 API，用 pw-play 播放 freedesktop 提示音）
    property string soundPath: "/run/current-system/sw/share/sounds/freedesktop/stereo/message.oga"

    property Process soundProc: Process {
        id: soundProc
        command: ["pw-play", root.soundPath]
    }

    function playSound() {
        if (root.soundProc.running) return;   // 正在播就跳过，避免叠加
        root.soundProc.command = ["pw-play", root.soundPath];
        root.soundProc.running = true;
    }

    function pushToast(n) {
        const next = root.toasts.concat([{ n: n, at: Date.now() }]);
        root.toasts = next.slice(-root.maxToasts);
    }

    // 从卡片队列移除（不关闭通知，历史仍保留）
    function removeToast(n) {
        root.toasts = root.toasts.filter(t => t.n !== n);
    }

    // 清理超时卡片
    function pruneToasts() {
        const now = Date.now();
        const next = root.toasts.filter(t => now - t.at < root.toastMs);
        if (next.length !== root.toasts.length) root.toasts = next;
    }

    Timer {
        interval: 500
        repeat: true
        running: root.toasts.length > 0
        onTriggered: root.pruneToasts()
    }

    // 从历史中移除一条（会触发通知的 closed 信号）
    function dismiss(n) {
        root.removeToast(n);
        n.dismiss();
    }

    // 清空全部历史
    function clearAll() {
        const list = server.trackedNotifications.values.slice();
        for (let i = 0; i < list.length; i++) root.dismiss(list[i]);
    }
}
