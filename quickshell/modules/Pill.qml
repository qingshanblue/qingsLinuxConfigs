// 通用深色药丸：三个区域（左/中/右）都用它。子元素会被放进内部 Row 中横向排列。
import QtQuick
import qs

Rectangle {
    id: pill

    default property alias content: row.data

    implicitHeight: Theme.pillHeight
    implicitWidth: row.implicitWidth + Theme.pillPadding * 2
    radius: height / 2
    color: Theme.pillBg
    border.color: Theme.pillBorder
    border.width: 1

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Theme.pillPadding
        spacing: Theme.spacing
    }
}
