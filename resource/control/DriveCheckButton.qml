import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

RadioButton {
    spacing: 2 * config_id.screenScale
    font.pixelSize: 12 * config_id.screenScale
    contentItem: Text {
             text: parent.text
             font: parent.font
             opacity: enabled ? 1.0 : 0.3
             color: "#000000"
             verticalAlignment: Text.AlignVCenter
             leftPadding: parent.indicator.width + parent.spacing
         }

    indicator: Image{
        width: 20 * config_id.screenScale
        height: 20 * config_id.screenScale
        anchors.verticalCenter: parent.verticalCenter
        source: parent.checked ? "qrc:///resource/image/simulation_page/icon_edit_property_radiobutton_checked.png"
                               :"qrc:///resource/image/simulation_page/icon_edit_property_radiobutton_normal.png"
    }
}
