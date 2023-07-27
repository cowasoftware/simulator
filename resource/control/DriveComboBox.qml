import QtQuick 2.15
import QtQuick.Controls 2.15

import COWA.Simulator  1.0

ComboBox{
    id: control
    // property var type : ""

    font.pixelSize: 14 * config_id.screenScale
    background: Rectangle{
        border.width: 1
        border.color: "#BBBBBB"
        radius: 4
    }

    delegate: ItemDelegate {
        width: control.width
        height: control.availableHeight
        contentItem: Text {
            text: model.text
            color: "#000000"
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        highlighted: control.highlightedIndex === index
    }

    indicator: Canvas {
        id: canvas1
        x: control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2
        width: 12 * config_id.screenScale
        height: 8 * config_id.screenScale
        contextType: "2d"

        Connections {
            target: control
            function onPressedChanged() { 
                if (config_id.isDebugLog) { console.log("canvas1.requestPaint 41")}
                canvas1.requestPaint(); }
        }

        onPaint: {
            context.reset();
            context.moveTo(0, 0);
            context.lineTo(width, 0);
            context.lineTo(width / 2, height);
            context.closePath();
            context.fillStyle = control.pressed ? "#BBBBBB" : "#BBBBBB";
            context.fill();
        }
    }

    popup: Popup {
        y: control.height - 1
        width: control.width
        implicitHeight: contentItem.implicitHeight+ 2
        padding: 1

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex


            ScrollIndicator.vertical: ScrollIndicator { }
        }

        background: Rectangle {
            border.color: "#BBBBBB"
            radius: 2
        }
    }
}
