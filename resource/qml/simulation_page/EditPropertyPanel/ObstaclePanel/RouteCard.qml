import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import "qrc:/resource/control"
import "../../../../control"
Control{
    contentItem: ColumnLayout{
        Label{
            horizontalAlignment: Text.AlignLeft
            text: qsTr("关联路线")
            font.pixelSize: 12 * config_id.screenScale
            color: "#000000"
        }

        ColumnLayout{
            Layout.leftMargin: 24 * config_id.screenScale
            Label{
                horizontalAlignment: Text.AlignRight
                text: qsTr("路线 - 15")
                font.pixelSize: 12 * config_id.screenScale
                color: "#101010"
            }
        }
    }
}
