// 通用深色药丸：三个区域（左/中/右）都用它。子元素会被放进内部 Row 中横向排列。
import QtQuick
import qs

Rectangle {
    id: pill

    default property alias content: row.data

    // 内容自然宽度（未受限），供外部做限宽计算
    readonly property real naturalWidth: row.implicitWidth + Theme.pillPadding * 2
    // 可被外部限制：默认跟随内容
    property real widthLimit: Number.POSITIVE_INFINITY

    implicitHeight: Theme.pillHeight
    implicitWidth: Math.min(naturalWidth, widthLimit)
    radius: height / 2
    color: Theme.pillBg
    border.color: Theme.pillBorder
    border.width: 1
    // 硬保障：即使外部宽度预算有漏算，内容也绝不会画出药丸外（旧版本就曾因此让
    // 长窗口标题探出黑色药丸、并把渐隐遮罩的直角边晾在壁纸上）。
    clip: true

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.pillPadding
        spacing: Theme.spacing

    }
}
