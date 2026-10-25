// 控制面板：单个 PopupWindow，由 kind 决定只渲染哪一块内容（每个模块各自的面板）。
// kind 取值：volume / network / bluetooth / brightness / battery（含电源档位）/ notify（通知中心）；空串表示未打开。
// 同一时间只开一个面板：点其他模块时复用同一窗口，切换 kind 与锚点。
// 不使用多个 PopupWindow 同时 grab：xdg popup 对嵌套/并存的抓取弹窗有父子规则，多窗口会互相干扰。
//
// 收起方式：
//   1. 点面板外（grabFocus：合成器发出 popup_done，触发 closed 信号）；
//   2. 再次点击同一模块（由 Bar.qml 的点击层调用 openPanel）。
// 注意：按下即收起、释放才触发点击，二者之间会误重开，因此用 lastClosedMs 做短时间去抖。
import QtQuick
import Quickshell
import qs

PopupWindow {
    id: panel

    // 当前面板类型，决定渲染哪一块。空串表示未打开。
    property string kind: ""

    // 上次因"点面板外"收起的时间戳（毫秒），用于去抖
    property real lastClosedMs: 0

    // 出现/消失动画控制器：外部只改 anim.open，不要直接动 visible
    property PanelAnim anim: PanelAnim { target: panel }

    // 亮度百分比（由 Bar 从 Brightness 模块传入，只读展示）
    property int brightnessPercent: 0

    // 亮度写入完成，转发给 Bar 去立即刷新 Brightness 模块
    signal brightnessChanged()

    implicitWidth: Theme.panelWidth

    // 面板可用高度：取所在屏幕高度减去状态栏与上下留白，保证不超出屏幕
    readonly property int screenHeight: (panel.screen?.height ?? 900)
    readonly property int maxBodyHeight: Math.max(200, Math.min(620, panel.screenHeight - Theme.barHeight - 80))
    readonly property int contentHeight: Math.min(body.implicitHeight, panel.maxBodyHeight)
    implicitHeight: panel.contentHeight + Theme.panelPadding * 2

    // 面板自身透明，圆角背景由内部 Rectangle 绘制，使四角干净
    color: "transparent"
    visible: anim.surfaced
    // 恒定 true：PopupWindow 的抓取必须与「表面创建」同一时刻生效，绑到会变化的
        // 属性上（曾写成 anim.open）会让抓取请求与表面映射竞争而被丢弃，
        // 表现为「点面板外关不掉」。抓取的存续由 visible: anim.surfaced 控制。
        grabFocus: true

    // 锚定方式：贴在模块底边，水平居中于模块，超出屏幕时沿 X 方向滑入屏内
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.adjustment: PopupAdjustment.SlideX

    // 打开某模块的面板。同一模块再点一次则收起；点其他模块则切换内容并移动到该模块下方。
    // k: 面板类型（见上方 kind）；item: 锚定的模块
    function openPanel(k, item) {
        if (Date.now() - panel.lastClosedMs < 350) return;
        if (panel.anim.open && panel.anchor.item === item) {
            panel.anim.open = false;
            return;
        }
        // 切换面板类型时，离开音量面板就恢复默认目标
        if (volumeSection && k !== "volume") volumeSection.resetTarget();
        panel.kind = k;
        panel.anchor.item = item;
        panel.anim.open = true;
        // 每次打开电池面板时读取一次电源档位（不轮询）
        if (k === "battery") powerSection.refresh();
        // 打开通知中心即视为已读
        if (k === "notify") Notifs.unread = 0;
    }

    // 点面板外导致合成器关闭弹窗
    onClosed: {
        panel.lastClosedMs = Date.now();
        // 关闭面板时音量条恢复跟随系统默认设备
        if (volumeSection) volumeSection.resetTarget();
    }

    // 背景 + 内容一起做出现/消失动画：用同一个 Items 容器承载，
    // 保证圆角背景与内容同步缩放，不会出现「背景先到位、内容后到」的错位。
    Item {
        id: reveal
        // 不用 anchors.fill：y 要参与动画，anchors 会接管 y 导致冲突，改用显式几何
        x: 0
        width: parent.width
        height: parent.height
        opacity: panel.anim.progress
        scale: panel.anim.scaleFrom + (1 - panel.anim.scaleFrom) * panel.anim.progress
        y: panel.anim.offsetY * (1 - panel.anim.progress)
        transformOrigin: Item.Top      // 从锚点一侧（顶部药丸）展开

        Rectangle {
            anchors.fill: parent
            color: Theme.panelBg
            radius: Theme.panelRadius
            border.color: Theme.pillBorder
            border.width: 1
        }

        // 内容区可滚动：设备列表较长时用鼠标滚轮浏览
        Flickable {
            id: flick
            x: Theme.panelPadding
            y: Theme.panelPadding
            width: panel.implicitWidth - Theme.panelPadding * 2
            height: panel.contentHeight
            contentHeight: body.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: body.implicitHeight > panel.maxBodyHeight

            // 各块内容互斥显示：只有 kind 匹配的块 visible，Column 会忽略不可见子项的布局空间
            Column {
                id: body
                width: flick.width
                spacing: 12

                PanelVolume {
                    id: volumeSection
                    width: parent.width
                    visible: panel.kind === "volume"
                }

                PanelNetwork {
                    width: parent.width
                    visible: panel.kind === "network"
                }

                PanelBluetooth {
                    width: parent.width
                    visible: panel.kind === "bluetooth"
                }

                PanelBrightness {
                    width: parent.width
                    percent: panel.brightnessPercent
                    visible: panel.kind === "brightness"
                    onApplied: panel.brightnessChanged()
                }

                // 电池面板：电量 + 电源档位（电源档位归属电池，不设独立入口）
                PanelBattery {
                    width: parent.width
                    visible: panel.kind === "battery"
                }

                PanelPowerProfile {
                    id: powerSection
                    width: parent.width
                    visible: panel.kind === "battery"
                }

                // 通知中心（历史列表较长，内部高度有上限）
                PanelNotify {
                    width: parent.width
                    visible: panel.kind === "notify"
                }
            }
        }
    }
}
