pragma Singleton

// 全局主题单例：颜色、尺寸、字体。所有模块只从这里取值，避免魔法数字散落各处。
// 颜色沿用用户 waybar CSS 的取值；药丸背景与边框为本阶段约定。
import QtQuick

QtObject {
    // ---- 尺寸 ----
    readonly property int barHeight: 32        // 整条状态栏高度（含上下留白）
    readonly property int pillHeight: 24       // 药丸高度，圆角 = 高度的一半
    readonly property int pillPadding: 10      // 药丸左右内边距
    readonly property int spacing: 8           // 药丸内模块之间的间距
    readonly property int outerMargin: 6       // 左右药丸离屏幕边缘的距离
    readonly property int trayIconSize: 16     // 托盘图标尺寸

    // ---- 药丸 ----
    readonly property color pillBg: Qt.rgba(18 / 255, 18 / 255, 18 / 255, 0.75)
    readonly property color pillBorder: Qt.rgba(1, 1, 1, 0.08)

    // ---- 模块颜色（来自 waybar CSS） ----
    readonly property color clockText: "#eefff1"
    readonly property color network: "#b0f5e5"
    readonly property color audio: "#a4e4fe"        // 音量 / 蓝牙
    readonly property color brightness: "#fe968b"
    readonly property color battery: "#ffeaaa"
    readonly property color charging: "#8fb2c9"
    readonly property color full: "#98c379"         // 电量满
    readonly property color windowTitle: "#e6f2d6"
    readonly property color tray: "#e0e0e0"
    readonly property color magic: "#89dceb"
    // 通知按钮（与 waybar custom/notification 一致）
    readonly property color notifyIdle: "#b0f5e5"    // 无未读
    readonly property color notifyUnread: "#eb4d4b"  // 有未读
    readonly property color notifyDnd: "#8fb2c9"     // 勿扰

    // ---- 工作区 ----
    readonly property color wsActiveBg: "#ffffff"
    readonly property color wsActiveText: "#000000"
    readonly property color wsOccupiedText: "#eefff1"
    readonly property color wsEmptyText: "#6c7086"

    // ---- 控制面板（第二阶段新增） ----
    readonly property color panelBg: "#121212"      // 面板背景，不透明（避免透明可读性问题）
    readonly property int panelWidth: 340            // 面板宽度
    readonly property int panelPadding: 14           // 面板内边距
    readonly property int panelRadius: 14            // 面板圆角
    readonly property color panelDivider: Qt.rgba(1, 1, 1, 0.08)
    readonly property color panelMuted: "#6c7086"    // 次要文字（与工作区空态同色）
    readonly property color panelText: "#cdd6f4"      // 面板主要文字（托盘菜单项等）

    // ---- 字体 ----
    readonly property string fontFamily: "Maple Mono NF CN"
    readonly property int fontSize: 13
    readonly property int fontWeight: Font.DemiBold   // 600
}
