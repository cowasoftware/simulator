import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Window 2.2
import QtQuick.Layouts 1.15
import QtQuick.Controls.Styles 1.4

CheckBox {
    id : control
    checked : false
    indicator: Rectangle {
        implicitWidth: 12
        implicitHeight: 12
        x: control.leftPadding
        y: parent.height / 2 - height / 2
        radius: 3
        border.color: "#FFFFFF"

        Rectangle {
            width: 8
            height: 8
            x: 2
            y: 2
            radius: 2
            visible: control.checked
            color: "red"
        }
    }

    contentItem: Text {
        text: control.text
        font: control.font
        opacity: enabled ? 1.0 : 0.3
        verticalAlignment: Text.AlignVCenter
        leftPadding: control.indicator.width + control.spacing
    }
}