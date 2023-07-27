import QtQuick 2.15
import QtQuick.Controls 2.15

AbstractButton {

    property alias cover: cover_id.source
    property alias title: title_id.text

    id: control
    implicitWidth: 200 * config_id.screenScale
    implicitHeight: 160 * config_id.screenScale
    contentItem: Item{
        Image
        {
            id: cover_id
            width: 200 * config_id.screenScale
            height: 120 * config_id.screenScale
            source: "qrc:///resource/image/home_page/project_sample_image.png"
            fillMode: Image.PreserveAspectFit
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle{
                    id: project_sample_image_border_id
                    width: parent.width
                    height: parent.height
                    radius: 12
                    color: 'transparent'
                    border.color: control.hovered ? "#3291F8" : "#00000000"
            }
        }

        Text
        {
            id: title_id
            width: control.width
            height: 19 * config_id.screenScale
            text: control.title
            font.styleName: "Regular"
            font.pixelSize: 12 * config_id.screenScale
            color: "#000000"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            anchors.top: cover_id.bottom
            anchors.topMargin: 13 * config_id.screenScale
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
