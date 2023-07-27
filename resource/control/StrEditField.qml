import QtQuick 2.12
import QtGraphicalEffects 1.12

import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

TextField{
    readonly property alias title: lblTitle
    id: control
    implicitWidth: 120 * config_id.screenScale
    implicitHeight: 30 * config_id.screenScale
    leftPadding: lblTitle.contentWidth
    horizontalAlignment: TextField.AlignRight
    verticalAlignment: TextField.AlignVCenter
    font.pixelSize: 12 * config_id.screenScale
    color: "#000000"
    selectByMouse: true
    selectionColor: "#999999"//选中背景颜色

    background: Item{
        Rectangle{
            anchors.left: lblTitle.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            border.width: 1
            border.color: control.focus ? "#3291F8" : "transparent"
        }

        Label{
            id: lblTitle
            width: control.leftPadding
            height: parent.height
            anchors.left: parent.left
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 12 * config_id.screenScale
            color: "#8CA2AA"
        }
    }
}
