import QtQuick 2.12
import QtGraphicalEffects 1.12

import QtQuick 2.0
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

TextField{
    readonly property  alias icon: imgIcon
    readonly property alias title: lblTitle
    readonly property alias tips: lblTips
    readonly property real value: text.length !==0 ? parseFloat(text) : 0.0
    readonly property alias unit: lblUnit
    readonly property alias interval: valueValidator
    id: control
    implicitWidth: 100 * config_id.screenScale
    implicitHeight: 30 * config_id.screenScale
    leftPadding: lblTitle.contentWidth
    rightPadding: lblUnit.contentWidth
    horizontalAlignment: TextField.AlignRight
    verticalAlignment: TextField.AlignVCenter
    font.pixelSize: 12 * config_id.screenScale
    color: "#000000"
    selectByMouse: true
    selectionColor: "#999999"//选中背景颜色
    validator: DoubleValidator{
        id: valueValidator
    }

    background: Item{
        Rectangle{
            anchors.left: lblTitle.right
            anchors.top: parent.top
            anchors.right: lblUnit.left
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

            Image{
                id: imgIcon
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
            }
            // for tips
            MouseArea{
                property bool entered: false
                hoverEnabled: true
                anchors.fill: parent
                onEntered: {
                    entered = true
                }

                onExited: {
                    entered = false
                }
                ToolTip{
                    id : lblTips
                    visible: parent.entered && text !=""
                    delay: 500
                }
            }
        }

        Label{
            id: lblUnit
            anchors.right: parent.right
            width: control.rightPadding - 2
            height: parent.height
            horizontalAlignment: TextField.AlignLeft
            verticalAlignment: TextField.AlignVCenter
            font.pixelSize: 12 * config_id.screenScale
        }
    }
}
