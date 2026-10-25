// 魔法棒按钮（special:magic / mofa / maho）
//   左键：切换最近使用的特殊工作区（多屏感知：在本屏则切换，在别屏则聚焦过去）
//   滚轮：在 magic → mofa → maho 之间循环切换
// 全部走 Hyprland.dispatch，不调用外部脚本。
import QtQuick
import Quickshell.Hyprland
import qs

Text {
    id: btn

    text: "󰁨"   // md-auto_fix (F0068)，与 waybar 的 custom/scratchpad 一致
    color: Theme.magic
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight

    // 特殊工作区轮换顺序
    readonly property var order: ["magic", "mofa", "maho"]

    // 上次使用的特殊区，重启后会回到 magic
    property string lastSpecial: "magic"

    // 找持有某个特殊工作区的显示器名；没有则返回空
    function holderOf(name) {
        const mons = Hyprland.monitors.values ?? [];
        for (let i = 0; i < mons.length; i++) {
            const sp = mons[i].lastIpcObject?.specialWorkspace?.name ?? "";
            if (sp === "special:" + name) return mons[i].name;
        }
        return "";
    }

    // 切换指定特殊区：本屏就切换显示/隐藏，别屏则把焦点移过去
    function toggleSpecial(name) {
        const holder = btn.holderOf(name);
        const cur = Hyprland.focusedMonitor?.name ?? "";
        if (holder !== "" && holder === cur) {
            Hyprland.dispatch('hl.dsp.workspace.toggle_special("' + name + '")');
        } else if (holder !== "") {
            Hyprland.dispatch('hl.dsp.focus({monitor="' + holder + '"})');
        } else {
            Hyprland.dispatch('hl.dsp.workspace.toggle_special("' + name + '")');
        }
        btn.lastSpecial = name;
    }

    // 当前焦点屏上的特殊工作区名（去掉 special: 前缀）
    function currentSpecial() {
        const sp = Hyprland.focusedMonitor?.lastIpcObject?.specialWorkspace?.name ?? "";
        return sp.indexOf("special:") === 0 ? sp.slice(8) : "";
    }

    // 在 order 中前后移动
    function cycle(step) {
        const cur = btn.currentSpecial();
        let idx = btn.order.indexOf(cur);
        if (idx < 0) idx = btn.order.indexOf(btn.lastSpecial);
        if (idx < 0) idx = 0;
        const next = btn.order[(idx + step + btn.order.length) % btn.order.length];
        btn.toggleSpecial(next);
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: btn.toggleSpecial(btn.lastSpecial)

        onWheel: wheel => {
            btn.cycle(wheel.angleDelta.y > 0 ? -1 : 1);
        }
    }
}
