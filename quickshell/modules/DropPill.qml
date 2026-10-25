// 贴顶面板：上缘与屏幕顶边融合（无边框、直角），底边平直，下方两角圆角与底边相切。
// 形状参数固定，宽度/高度变化时轮廓比例保持一致。
import QtQuick
import qs

Item {
    id: root

    default property alias content: inner.data

    property int contentWidth: 100
    property int contentHeight: 18
    // 纵向内边距：上下等距，文字在面板内真正居中
    property int vPadding: 7
    property int sidePadding: Theme.pillPadding
    // 下方两角圆角半径（固定值，各屏一致）
    property real cornerRadius: 999   // 取 min(w/2) 即为半圆底

    implicitWidth: contentWidth + sidePadding * 2
    implicitHeight: contentHeight + vPadding * 2

    Canvas {
        id: shape
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            var w = width, h = height;
            // 圆角只受宽度限制（高度不再卡住圆角，否则小高度时圆角被压平）
            var r = Math.min(root.cornerRadius, w / 2);

            ctx.beginPath();
            ctx.moveTo(0, 0);
            ctx.lineTo(0, h - r);
            // 左下圆角：与底边相切（r 大于高度时自然形成大弧）
            ctx.quadraticCurveTo(0, h, r, h);
            // 底边直线
            ctx.lineTo(w - r, h);
            // 右下圆角：与底边相切
            ctx.quadraticCurveTo(w, h, w, h - r);
            ctx.lineTo(w, 0);
            ctx.closePath();

            ctx.fillStyle = Theme.pillBg;
            ctx.fill();

            // 边框：只描三边（左、下、右），顶边不描，与屏幕边缘融合
            ctx.beginPath();
            ctx.moveTo(0, h - r);
            ctx.quadraticCurveTo(0, h, r, h);
            ctx.lineTo(w - r, h);
            ctx.quadraticCurveTo(w, h, w, h - r);
            ctx.strokeStyle = Theme.pillBorder;
            ctx.lineWidth = 1;
            ctx.stroke();
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Connections {
            target: Theme
            function onPillBgChanged() { shape.requestPaint() }
            function onPillBorderChanged() { shape.requestPaint() }
        }
    }

    // 内容在整个面板内垂直居中（面板上缘贴屏，但文字居中更好看）
    Item {
        id: inner
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: root.contentWidth
        height: root.contentHeight
    }
}
