// 面板出现 / 消失动画控制器（非视觉，作为 PopupWindow 的一个属性挂载）。
//
// 为什么需要它：Wayland 的弹窗表面一旦销毁就再也渲染不出来，所以「消失动画」必须先跑动画、
// 再销毁表面。QML 里又没法直接对 Window 做 opacity/scale（Window 不是可视项），
// 只能给窗口内部的「内容根」加动画。于是把这两件事收在一个控制器里，各面板只接三根线：
//
//   PopupWindow {
//       id: popup
//       property PanelAnim anim: PanelAnim { target: popup }   // 1. 挂控制器
//       visible: anim.surfaced                                  // 2. 表面存活 = 打开中 或 退出动画未跑完
//       grabFocus: true                                        // 3. 恒定 true（切勿绑到 anim.open，见下方说明）
//
//       内容根 {                                                // 4. 动画作用在内容根上
//           opacity: anim.progress
//           scale: anim.scaleFrom + (1 - anim.scaleFrom) * anim.progress
//           y: anim.offsetY * (1 - anim.progress)
//           transformOrigin: Item.Top    // 从锚点那一侧（顶部）展开
//       }
//   }
//
// 外部只改 anim.open（true 打开 / false 收起），不要直接动 popup.visible。
//
// 【为什么 grabFocus 必须写死 true，不能绑 anim.open】
// PopupWindow 的键盘/指针抓取要在「表面创建」的同一时刻向合成器申请，并且此后一直持有。
// 曾经写成 grabFocus: anim.open，结果抓取请求与表面映射竞争、被合成器丢弃（表面刚建出来
// 那一帧抓取请求还没生效），于是合成器永远不发 popup_done —— 表现为「点面板外关不掉」。
// 抓取的存续周期改由 visible: anim.surfaced 控制：表面在，抓取就在；表面销毁，抓取自然释放。
//
// 已知限制：被合成器「点面板外」关闭时（popup_done），表面是被合成器直接撤掉的，
// 我们来不及播消失动画，只能同步状态立即收尾。也就是说消失动画只在「我们自己关」的场景可见
// （例如托盘菜单点完一项、命令行/代码里收起）。出现动画不受此限，全部可见。
import QtQuick
import qs

Item {
    id: anim

    // 控制器自身不参与渲染（作为属性挂载时本来就不在可视树里，这里再兜一层）
    visible: false
    implicitWidth: 0
    implicitHeight: 0

    // 目标 PopupWindow。用于监听它被合成器关闭（closed 信号），同步内部状态。
    property var target: null

    // 逻辑开关：外部只改这个
    property bool open: false

    // 动画进度：0 = 完全收起，1 = 完全展开。内容根的所有动画属性都由它派生，
    // 这样「出现」和「消失」共用一条时间轴，不会出现两套属性互相打架。
    property real progress: 0

    // 表面是否需要存在：打开瞬间就需要；关闭后要等退出动画跑完才销毁。
    property bool surfaced: false

    readonly property int enterMs: Theme.panelEnterMs
    readonly property int exitMs: Theme.panelExitMs
    readonly property real scaleFrom: Theme.panelScaleFrom
    readonly property real offsetY: Theme.panelOffsetY

    onOpenChanged: {
        if (open) {
            exitTimer.stop();
            surfaced = true;      // 先建表面
            progress = 1;         // 由 Behavior 从当前值动画到 1
        } else {
            progress = 0;         // 由 Behavior 动画到 0（退出动画）
            exitTimer.restart();  // 动画跑完再撤表面
        }
    }

    // 被合成器关闭（点面板外）：表面已经没了，没法播动画，只能立刻对齐状态，
    // 否则 open 会一直停在 true，下次打开不会再播出现动画。
    Connections {
        target: anim.target

        function onClosed() {
            // 注意：这里必须用裸 id `exitTimer`，不能写 `anim.exitTimer`
            // —— id 不是属性，`anim.<id>` 永远解析不到，会报 TypeError。
            exitTimer.stop();
            anim.open = false;
            anim.progress = 0;
            anim.surfaced = false;
        }
    }

    // 退出动画播完 → 撤掉表面。多给 20ms 余量，避免最后一帧被截断。
    Timer {
        id: exitTimer
        interval: anim.exitMs + 20
        onTriggered: if (!anim.open) anim.surfaced = false
    }

    Behavior on progress {
        NumberAnimation {
            duration: anim.open ? anim.enterMs : anim.exitMs
            easing.type: anim.open ? Easing.OutCubic : Easing.InCubic
        }
    }
}
