import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12

import COWA.Simulator 1.0

ComboBox{
    ListModel{
        id: playbackModel
        Component.onCompleted: {
            // for(var i=0;i<100;i++){
            //     playbackModel.append({"value":i,"text":"紧急制动刹车防止碰撞-" + i})
            // }
            var recordModel = RecordPlayControl.acquireRecord()
            if (recordModel != null) {
                var list_files = recordModel.recordfiles
                for (var i = 0; i < list_files.length; ++i) {
                    playbackModel.append({"value" : i, "text" : list_files[i] })
                }
            }
        }
    }

    Connections {
        target : RecordPlayControl
        function onNotifyRecord(model) {
            if (model != null) {
                playbackModel.clear()
                var list_files = model.recordfiles
                for (var i = 0; i < list_files.length; ++i) {
                    playbackModel.append({"value" : i, "text" : list_files[i] })
                }

            }
        }
    }

    id: control
    leftPadding: 24 * config_id.screenScale
    font.pixelSize: 12 * config_id.screenScale
    background: Item{}

    valueRole: "value"
    textRole: "text"
    model: playbackModel

    indicator: Button{
        width: 18 * config_id.screenScale
        height: 18 * config_id.screenScale
        anchors.left: parent.left
        anchors.leftMargin: 10 * config_id.screenScale
        anchors.verticalCenter: parent.verticalCenter
        background: Item{}
        contentItem: Image{
            anchors.fill: parent
            source: "qrc:///resource/image/simulation_page/icon_tool_playback_list.png"
        }
        onClicked: parent.popup.open()
    }
    delegate: ItemDelegate{
        id: itemDelegate
        highlighted: control.currentIndex === index
        width: ListView.view.width
        height: 36
        leftPadding: 0
        background: Rectangle{
            color: parent.hovered ? "#E1E3E6" : "transparent"
        }

        contentItem: RowLayout{
            spacing: 9 * config_id.screenScale
            Item{
                Layout.preferredWidth: 18 * config_id.screenScale
                Layout.preferredHeight: 18 * config_id.screenScale

                Image{
                    anchors.fill: parent
                    visible: itemDelegate.highlighted
                    source: "qrc:///resource/image/simulation_page/icon_tool_playback_loading.png"
                }
            }

            Label{
                text: model.text
                font.pixelSize: 12 * config_id.screenScale
                color: itemDelegate.highlighted ? "#3591F8" : "#505559"
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }

            Item{
                Layout.fillWidth: true
            }
        }
    }

    popup: Popup{
        x: 0
        y: parent.height
        width: 230 * config_id.screenScale
        height: 200 * config_id.screenScale
        leftPadding: 10
        background: Rectangle{
            radius: 6
            Rectangle {
                id: bg
                anchors.fill: parent
                smooth: true
                visible: false
                radius: 6
            }

            DropShadow {
                anchors.fill: bg
                verticalOffset: 6
                radius: 12
                samples: 2 * radius +1
                color: "#23000000"
                source: bg
            }
        }

        contentItem: ListView{
            width: parent.availableWidth
            clip: true
            ScrollIndicator.vertical: ScrollIndicator {
                width: 8
            }
            model: control.popup.visible ? control.delegateModel : null
        }

    }
}
