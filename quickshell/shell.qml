//@ pragma UseQApplication
// 入口：遍历屏幕，只在 eDP-1（主屏）上创建状态栏。DP-1 不做状态栏。
import Quickshell
import "modules"

ShellRoot {
    // 只保留 eDP-1。用下标遍历而非 filter，兼容 Quickshell.screens 的列表类型。
    readonly property var barScreens: {
        const out = [];
        for (let i = 0; i < Quickshell.screens.length; i++) {
            const s = Quickshell.screens[i];
            if (s.name === "eDP-1") out.push(s);
        }
        return out;
    }

    Variants {
        model: barScreens

        // 每个状态栏屏配一个通知卡片窗口（同屏）
        Scope {
            required property var modelData

            Bar {
                screen: modelData
            }

            Toasts {
                screen: modelData
            }
        }
    }
}
