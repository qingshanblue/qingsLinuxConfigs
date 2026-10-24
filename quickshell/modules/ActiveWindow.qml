// 当前焦点窗口标题：限制最大像素宽度，超出用省略号，避免顶到右侧药丸。
// 同时限制字符数，避免超长标题影响布局计算。
import QtQuick
import Quickshell.Hyprland
import qs

Text {
    id: root

    readonly property string fullTitle: Hyprland.activeToplevel?.title ?? ""
    readonly property int maxChars: 40
    // 最大像素宽度：由 Bar 按屏幕宽度传入，保证左右药丸之间留有空间
    property int maxWidth: 320

    text: {
        const chars = Array.from(fullTitle);
        return chars.length > maxChars ? chars.slice(0, maxChars).join("") + "…" : fullTitle;
    }
    visible: fullTitle.length > 0
    width: Math.min(implicitWidth, maxWidth)
    elide: Text.ElideRight
    color: Theme.windowTitle
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight
}
