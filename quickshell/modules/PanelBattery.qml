// 面板 · 电池：百分比、状态、功率、容量、健康度、剩余时间；充电限制若硬件支持则显示。
// 数据来自 Quickshell.Services.UPower（事件驱动）+ sysfs 读取充电限制/循环次数。
import QtQuick
import Quickshell
import Quickshell.Services.UPower
import Quickshell.Io
import qs

Column {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property int percent: Math.round((root.device?.percentage ?? 0) * 100)
    readonly property int state: root.device?.state ?? UPowerDeviceState.Unknown

    readonly property string stateText: {
        switch (root.state) {
        case UPowerDeviceState.Charging: return "充电中";
        case UPowerDeviceState.Discharging: return "放电中";
        case UPowerDeviceState.FullyCharged: return "已充满";
        case UPowerDeviceState.PendingCharge: return "等待充电";
        case UPowerDeviceState.PendingDischarge: return "等待放电";
        case UPowerDeviceState.Empty: return "已耗尽";
        default: return "未知";
        }
    }

    // 功率（W），changeRate 为瓦特
    readonly property real watts: root.device?.changeRate ?? 0
    // 满电容量（Wh）与设计容量需从 sysfs 读；这里用 energyCapacity
    readonly property real energyCapacity: root.device?.energyCapacity ?? 0
    readonly property real energyNow: root.device?.energy ?? 0
    // 健康度（%），UPower 直接给出
    readonly property int health: Math.round(root.device?.healthPercentage ?? 0)
    readonly property bool healthSupported: root.device?.healthSupported ?? false

    // sysfs 读取：设计容量、循环次数、充电限制
    property int cycleCount: -1
    property int chargeLimit: -1

    spacing: 8

    // 设计容量：charge_full_design(µAh) × voltage_min_design(µV) → Wh
    FileView {
        path: "/sys/class/power_supply/BAT0/charge_full_design"
        blockLoading: true
        onLoaded: root.designCharge = Number(text()) || 0
    }

    FileView {
        path: "/sys/class/power_supply/BAT0/charge_full"
        blockLoading: true
        onLoaded: root.fullCharge = Number(text()) || 0
    }

    // 当前满电容量（µAh × µV → Wh）
    property real fullCharge: 0
    readonly property real fullWh: (root.fullCharge * root.designVoltage) / 1e12

    FileView {
        path: "/sys/class/power_supply/BAT0/voltage_min_design"
        blockLoading: true
        onLoaded: root.designVoltage = Number(text()) || 0
    }

    property real designCharge: 0
    property real designVoltage: 0
    readonly property real designWh: (root.designCharge * root.designVoltage) / 1e12

    FileView {
        path: "/sys/class/power_supply/BAT0/cycle_count"
        blockLoading: true
        onLoaded: root.cycleCount = Number(text()) || -1
    }

    // 充电限制：探测是否存在（不存在则明确显示"硬件不支持"）
    Process {
        running: true
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/charge_control_end_threshold 2>/dev/null || echo -1"]
        stdout: SplitParser {
            onRead: line => root.chargeLimit = Number(line.trim())
        }
    }

    function isMissing(v) { return v === undefined || v === null || isNaN(v); }

    // 标题行
    Row {
        width: parent.width

        Text {
            id: batLabel
            text: "电池"
            color: Theme.battery
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
        }

        Item {
            width: parent.width - batLabel.implicitWidth - batState.implicitWidth
            height: 1
        }

        Text {
            id: batState
            text: root.percent + "%  ·  " + root.stateText
            color: root.state === UPowerDeviceState.Charging ? Theme.charging
                 : root.state === UPowerDeviceState.FullyCharged ? Theme.full
                 : Theme.battery
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            font.weight: Theme.fontWeight
        }
    }

    // 进度条
    Rectangle {
        width: parent.width
        height: 6
        radius: 3
        color: Qt.rgba(1, 1, 1, 0.12)

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.percent / 100))
            height: parent.height
            radius: 3
            color: root.state === UPowerDeviceState.Charging ? Theme.charging
                 : root.state === UPowerDeviceState.FullyCharged ? Theme.full
                 : Theme.battery
        }
    }

    // 详情行
    Column {
        width: parent.width
        spacing: 3

        Repeater {
            model: root.details

            delegate: Item {
                id: dRow
                required property var modelData
                width: root.width
                height: 16

                Text {
                    id: kLabel
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: dRow.modelData.k
                    color: Theme.panelMuted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                    font.weight: Theme.fontWeight
                }

                Text {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: kLabel.right
                    anchors.leftMargin: 8
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideLeft
                    text: dRow.modelData.v
                    color: dRow.modelData.c ?? Theme.panelText
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize - 2
                    font.weight: Theme.fontWeight
                }
            }
        }
    }

    // 计算详情数组（依赖上面所有属性，变化时自动重算）
    readonly property var details: {
        const out = [];

        // 功率（插电满电时为 0，仍显示以便确认状态）
        if (!root.isMissing(root.watts))
            out.push({ k: "功率", v: root.watts.toFixed(2) + " W", c: Theme.audio });

        // 满电容量（按当前电池实际容量）
        if (root.fullWh > 0)
            out.push({ k: "满电容量", v: root.fullWh.toFixed(1) + " Wh" });

        // 设计容量
        if (root.designWh > 0)
            out.push({ k: "设计容量", v: root.designWh.toFixed(1) + " Wh" });

        // 健康度：优先 UPower，否则用 sysfs 的 满电容量/设计容量 计算
        let healthVal = 0;
        if (root.healthSupported && root.health > 0) healthVal = root.health;
        else if (root.fullWh > 0 && root.designWh > 0) healthVal = Math.round(root.fullWh / root.designWh * 100);
        if (healthVal > 0) {
            const c = healthVal >= 80 ? Theme.full : (healthVal >= 60 ? Theme.battery : Theme.notifyUnread);
            out.push({ k: "健康度", v: healthVal + "%", c: c });
        }

        // 剩余/充满时间
        const t = root.state === UPowerDeviceState.Charging ? root.device?.timeToFull : root.device?.timeToEmpty;
        if (t && t > 0) {
            const h = Math.floor(t / 3600);
            const m = Math.round((t % 3600) / 60);
            out.push({ k: root.state === UPowerDeviceState.Charging ? "充满剩余" : "剩余时间", v: h + " 小时 " + m + " 分" });
        }

        // 循环次数
        if (root.cycleCount >= 0)
            out.push({ k: "循环次数", v: root.cycleCount + " 次" });

        // 充电限制
        out.push({
            k: "充电限制",
            v: root.chargeLimit > 0 ? root.chargeLimit + "%" : "硬件不支持",
            c: root.chargeLimit > 0 ? Theme.panelText : Theme.panelMuted
        });

        return out;
    }
}
