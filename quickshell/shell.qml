//@ pragma UseQApplication
// 入口：遍历所有屏幕，每屏一个状态栏（workpaces 按本屏过滤，见 modules/Workspaces.qml）。
import Quickshell
import "modules"

ShellRoot {
    // 所有屏幕都放状态栏。用下标遍历而非 filter，兼容 Quickshell.screens 的列表类型。
    readonly property var barScreens: {
        const out = [];
        for (let i = 0; i < Quickshell.screens.length; i++) out.push(Quickshell.screens[i]);
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
