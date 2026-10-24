// 当前焦点窗口标题，截断到 40 个字符（按码点计，超出加省略号）。无焦点窗口时隐藏。
import QtQuick
import Quickshell.Hyprland
import qs

Text {
    id: root

    readonly property string fullTitle: Hyprland.activeToplevel?.title ?? ""
    readonly property int maxChars: 40

    text: {
        const chars = Array.from(fullTitle);
        return chars.length > maxChars ? chars.slice(0, maxChars).join("") + "…" : fullTitle;
    }
    visible: fullTitle.length > 0
    color: Theme.windowTitle
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontWeight
}
