// 计时器全局状态（单例）：秒表 / 定时器 / 闹钟
// 放在这里而不是每个屏幕的 Clock 实例里，否则两块屏幕各自独立、互不可见。
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    // ── 时钟（两屏共享同一时间源，避免各自计时漂移） ──
    property date now: new Date()

    property Timer clockTimer: Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            const d = new Date();
            // 秒变了才更新，减少无谓刷新
            if (d.getSeconds() !== root.now.getSeconds()) root.now = d;
        }
    }

    // ══════════════ 秒表 ══════════════
    property bool swRunning: false
    property real swElapsed: 0
    property real swStartStamp: 0
    property int swTick: 0
    property var swLaps: []

    function swToggle() {
        if (root.swRunning) {
            root.swElapsed += Date.now() - root.swStartStamp;
            root.swRunning = false;
        } else {
            root.swStartStamp = Date.now();
            root.swRunning = true;
        }
    }
    function swReset() {
        root.swRunning = false;
        root.swElapsed = 0;
        root.swLaps = [];
    }
    function swLap() {
        if (!root.swRunning) return;
        const cur = root.swElapsed + (Date.now() - root.swStartStamp);
        root.swLaps = root.swLaps.concat([cur]);
    }

    readonly property real swDisplay: {
        root.swTick;
        return root.swRunning ? root.swElapsed + (Date.now() - root.swStartStamp) : root.swElapsed;
    }

    property Timer swTimer: Timer {
        interval: 50
        running: root.swRunning
        repeat: true
        onTriggered: root.swTick++
    }

    function fmtMs(ms) {
        const t = Math.floor(ms);
        const m = Math.floor(t / 60000);
        const s = Math.floor((t % 60000) / 1000);
        const cs = Math.floor((t % 1000) / 10);
        return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s + "." + (cs < 10 ? "0" : "") + cs;
    }

    // ══════════════ 定时器 ══════════════
    property int tmTotal: 300
    property int tmLeft: 300
    property bool tmRunning: false
    property bool tmRinging: false
    property string tmCustom: ""

    function tmStart() {
        root.tmRinging = false;
        if (root.tmLeft > 0) root.tmRunning = true;
    }
    function tmPause() { root.tmRunning = false; }
    function tmReset() {
        root.tmRunning = false;
        root.tmRinging = false;
        root.tmLeft = root.tmTotal;
        root.stopRing();
    }
    function tmDismiss() {
        root.tmRinging = false;
        root.tmLeft = root.tmTotal;
        root.stopRing();
    }
    function tmSetMinutes(minutes) {
        const secs = Math.max(1, Math.round(minutes * 60));
        root.tmTotal = secs;
        root.tmLeft = secs;
        root.tmRunning = false;
        root.tmRinging = false;
        root.tmCustom = "";
        root.stopRing();
    }
    function applyCustom() {
        const n = parseInt(root.tmCustom);
        if (!isNaN(n) && n > 0) root.tmSetMinutes(n);
    }

    readonly property string tmText: {
        const m = Math.floor(root.tmLeft / 60);
        const s = root.tmLeft % 60;
        return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s;
    }

    property Timer tmTimer: Timer {
        interval: 1000
        running: root.tmRunning
        repeat: true
        onTriggered: {
            if (root.tmLeft > 0) root.tmLeft -= 1;
            if (root.tmLeft <= 0) {
                root.tmRunning = false;
                root.tmRinging = true;
                root.startRing();
            }
        }
    }

    // ══════════════ 闹钟（支持多个，分页显示） ══════════════
    // 每个闹钟：{ h, m, on }  on=true 表示已启用
    property var alarms: [
        { h: 7, m: 0, on: false },
        { h: 8, m: 0, on: false }
    ]
    // 当前编辑/查看的闹钟索引
    property int alIndex: 0
    // 是否正在响铃，以及是哪个闹钟在响
    property bool alRinging: false
    property int alRingingIndex: -1
    readonly property int alSnoozeMin: 5

    readonly property int alCount: root.alarms.length
    readonly property var alCur: root.alarms[root.alIndex] ?? { h: 7, m: 0, on: false }
    readonly property int alHour: root.alCur.h ?? 7
    readonly property int alMinute: root.alCur.m ?? 0
    readonly property bool alEnabled: root.alCur.on ?? false

    readonly property string alText: (root.alHour < 10 ? "0" : "") + root.alHour
        + ":" + (root.alMinute < 10 ? "0" : "") + root.alMinute

    readonly property bool anyAlarmOn: {
        for (let i = 0; i < root.alarms.length; i++)
            if (root.alarms[i].on) return true;
        return false;
    }

    // 更新单个闹钟（值语义：复制数组再替换，触发 QML 绑定刷新）
    function setAlarm(idx, patch) {
        const arr = root.alarms.slice();
        if (idx < 0 || idx >= arr.length) return;
        arr[idx] = Object.assign({}, arr[idx], patch);
        root.alarms = arr;
    }

    function alArm() {
        root.alRinging = false;
        root.stopRing();
        root.setAlarm(root.alIndex, { on: true });
    }
    function alDisarm() {
        root.alRinging = false;
        root.stopRing();
        root.setAlarm(root.alIndex, { on: false });
    }
    function alDismiss() {
        root.alRinging = false;
        root.stopRing();
        if (root.alRingingIndex >= 0) {
            root.setAlarm(root.alRingingIndex, { on: false });
            root.alRingingIndex = -1;
        }
    }
    // 稍后提醒：停铃，把该闹钟改到 5 分钟后并保持启用
    function alSnooze() {
        root.alRinging = false;
        root.stopRing();
        const idx = root.alRingingIndex;
        if (idx >= 0) {
            const d = new Date(Date.now() + root.alSnoozeMin * 60000);
            root.setAlarm(idx, { h: d.getHours(), m: d.getMinutes(), on: true });
            root.alRingingIndex = -1;
        }
    }
    function alAddMinutes(delta) {
        let total = root.alHour * 60 + root.alMinute + delta;
        total = ((total % 1440) + 1440) % 1440;
        root.setAlarm(root.alIndex, { h: Math.floor(total / 60), m: total % 60 });
    }
    function alAdd(idx, delta) {
        const arr = root.alarms.slice();
        if (idx < 0 || idx >= arr.length) return;
        let total = (arr[idx].h * 60) + arr[idx].m + delta;
        total = ((total % 1440) + 1440) % 1440;
        arr[idx] = Object.assign({}, arr[idx], { h: Math.floor(total / 60), m: total % 60 });
        root.alarms = arr;
    }
    function alAddNew() {
        const arr = root.alarms.slice();
        arr.push({ h: 7, m: 0, on: false });
        root.alarms = arr;
        root.alIndex = arr.length - 1;
    }
    function alRemove(idx) {
        if (root.alarms.length <= 1) return;
        const arr = root.alarms.slice();
        arr.splice(idx, 1);
        root.alarms = arr;
        if (root.alIndex >= arr.length) root.alIndex = arr.length - 1;
    }

    property Timer alTimer: Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            if (root.alRinging) return;
            const d = new Date();
            if (d.getSeconds() !== 0) return;
            for (let i = 0; i < root.alarms.length; i++) {
                const a = root.alarms[i];
                if (!a.on) continue;
                if (d.getHours() === a.h && d.getMinutes() === a.m) {
                    root.alRinging = true;
                    root.alRingingIndex = i;
                    root.startRing();
                    break;
                }
            }
        }
    }

    // ══════════════ 响铃 ══════════════
    readonly property string ringSound: "/run/current-system/sw/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"
    // 避免两块屏幕各播一次：只在单例里播
    property Process ringProc: Process {
        id: ringProc
    }

    function playRingOnce() {
        ringProc.command = ["pw-play", root.ringSound];
        ringProc.running = true;
    }
    function startRing() {
        root.playRingOnce();
        ringTimer.restart();
    }
    function stopRing() {
        ringTimer.stop();
    }

    property Timer ringTimer: Timer {
        id: ringTimer
        interval: 3000
        running: false
        repeat: true
        onTriggered: {
            if (root.tmRinging || root.alRinging) root.playRingOnce();
            else ringTimer.stop();
        }
    }

    // ══════════════ 状态汇总（给图标用） ══════════════
    // 允许同时运行多个，图标需要能同时表达
    readonly property bool anyRunning: root.swRunning || root.tmRunning || root.alEnabled
    readonly property bool anyRinging: root.tmRinging || root.alRinging
}
